import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Ganti IP ini jika alamat laptop berubah saat aplikasi dijalankan di HP.
const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.0.100:8090',
);

const Color navy = Color(0xFF183B56);
const Color teal = Color(0xFF17A398);
const Color pageBg = Color(0xFFF4F7FA);

// Foto destinasi untuk kartu wishlist. URL Unsplash dapat diganti kapan saja.
String? destinationImageFor(String destination, String location) {
  final key = '$destination $location'.toLowerCase();
  if (key.contains('bali')) {
    return 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=500&auto=format&fit=crop&q=80';
  }
  if (key.contains('raja ampat')) {
    return 'https://images.unsplash.com/photo-1601844075967-c1376c021732?w=500&auto=format&fit=crop&q=80';
  }
  if (key.contains('bromo')) {
    return 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=500&auto=format&fit=crop&q=80';
  }
  if (key.contains('prambanan') || key.contains('yogyakarta') || key.contains('jogja')) {
    return 'https://images.unsplash.com/photo-1584810359583-96fc3448beaa?w=500&auto=format&fit=crop&q=80';
  }
  if (key.contains('labuan bajo') || key.contains('komodo')) {
    return 'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?w=500&auto=format&fit=crop&q=80';
  }
  if (key.contains('pantai') || key.contains('pulau') || key.contains('laut')) {
    return 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?w=500&auto=format&fit=crop&q=80';
  }
  if (key.contains('gunung') || key.contains('mountain')) {
    return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500&auto=format&fit=crop&q=80';
  }
  return null;
}

void main() => runApp(const TravelWishlistApp());

class Api {
  static String? token;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<Map<String, dynamic>> post(String path, Map body) async {
    final r = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _decode(r);
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final r = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
    return _decode(r);
  }

  static Future<Map<String, dynamic>> put(String path, Map body) async {
    final r = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _decode(r);
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final r = await http.delete(Uri.parse('$baseUrl$path'), headers: headers);
    return _decode(r);
  }

  static Map<String, dynamic> _decode(http.Response r) {
    final data = jsonDecode(r.body);
    if (data is Map<String, dynamic>) {
      if (r.statusCode >= 400 || data['success'] == false) {
        throw Exception(data['message'] ?? 'Permintaan gagal (${r.statusCode})');
      }
      return data;
    }
    throw Exception('Respons server tidak valid.');
  }
}

class TravelWishlistApp extends StatelessWidget {
  const TravelWishlistApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Travel Wishlist',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(seedColor: teal),
          scaffoldBackgroundColor: pageBg,
          appBarTheme: const AppBarTheme(
            backgroundColor: pageBg,
            foregroundColor: navy,
            elevation: 0,
            centerTitle: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE7EDF2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: teal, width: 1.5),
            ),
          ),
        ),
        home: const SessionGate(),
      );
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});
  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool checking = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    Api.token = p.getString('token');
    if (Api.token != null) {
      try {
        await Api.get('/api/auth/me.php');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        return;
      } catch (_) {
        await p.remove('token');
        Api.token = null;
      }
    }
    if (mounted) setState(() => checking = false);
  }

  @override
  Widget build(BuildContext context) => checking
      ? const Scaffold(
          body: Center(child: CircularProgressIndicator(color: teal)))
      : const AuthPage();
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false;
  bool busy = false;
  bool hidePassword = true;
  String? error;

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = 'Email dan password wajib diisi.');
      return;
    }
    if (register && name.text.trim().isEmpty) {
      setState(() => error = 'Nama wajib diisi.');
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final result = await Api.post(
        register ? '/api/auth/register.php' : '/api/auth/login.php',
        {
          if (register) 'name': name.text.trim(),
          'email': email.text.trim(),
          'password': password.text,
        },
      );
      Api.token = result['data']['token'];
      final p = await SharedPreferences.getInstance();
      await p.setString('token', Api.token!);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 48, 28, 42),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF183B56), Color(0xFF17A398)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(38)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 82,
                        width: 82,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.17),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.travel_explore,
                            size: 45, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Travel Wishlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Simpan tempat impian, mulai petualanganmu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          register ? 'Buat akun baru' : 'Selamat datang!',
                          style: const TextStyle(
                            color: navy,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          register
                              ? 'Daftar untuk mulai menyimpan destinasi favorit.'
                              : 'Masuk dan lanjutkan rencana perjalananmu.',
                          style: const TextStyle(
                              color: Color(0xFF778592), fontSize: 14),
                        ),
                        const SizedBox(height: 25),
                        if (register) ...[
                          TextField(
                            controller: name,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nama lengkap',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: password,
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => hidePassword = !hidePassword),
                              icon: Icon(hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                            ),
                          ),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 14),
                          Text(error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13)),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 54,
                          child: FilledButton(
                            onPressed: busy ? null : submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: busy
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : Text(
                                    register ? 'DAFTAR SEKARANG' : 'MASUK',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => setState(() {
                                    register = !register;
                                    error = null;
                                  }),
                          child: Text(
                            register
                                ? 'Sudah punya akun? Login'
                                : 'Belum punya akun? Daftar sekarang',
                            style: const TextStyle(
                                color: navy, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List items = [];
  bool loading = true;
  String? error;
  String query = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final r = await Api.get('/api/wishlists/index.php');
      items = r['data'] ?? [];
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('token');
    Api.token = null;
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (_) => false,
    );
  }

  Future<void> openForm([Map? item]) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WishlistForm(item: item)),
    );
    if (changed == true) load();
  }

  Future<void> remove(Map item) async {
    try {
      await Api.delete('/api/wishlists/delete.php?id=${item['id']}');
      load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wishlist berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [_homeContent(), _exploreContent(), _wishlistContent(), _profileContent()];
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(child: IndexedStack(index: selectedTab, children: pages)),
      floatingActionButton: selectedTab == 0 || selectedTab == 2
          ? FloatingActionButton.extended(
              onPressed: () => openForm(), backgroundColor: teal,
              foregroundColor: Colors.white, icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Tambah tempat', style: TextStyle(fontWeight: FontWeight.bold)))
          : null,
      bottomNavigationBar: NavigationBar(
        height: 72, selectedIndex: selectedTab,
        backgroundColor: Colors.white, indicatorColor: teal.withValues(alpha: .13),
        onDestinationSelected: (v) => setState(() => selectedTab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Wishlist'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _homeContent() => RefreshIndicator(
    onRefresh: load,
    child: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 110), children: [
      Row(children: [
        Container(width: 43, height: 43, decoration: BoxDecoration(color: teal.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.travel_explore, color: teal)),
        const SizedBox(width: 11), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TRAVEL WISHLIST', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: teal, fontWeight: FontWeight.w900)), Text('Hai, Traveler! 👋', style: TextStyle(fontSize: 19, color: navy, fontWeight: FontWeight.w900))])),
        IconButton(onPressed: logout, icon: const Icon(Icons.logout_rounded, color: navy), tooltip: 'Keluar'),
      ]),
      const SizedBox(height: 20),
      ClipRRect(borderRadius: BorderRadius.circular(26), child: Stack(children: [
        Image.network('https://images.unsplash.com/photo-1530789253388-582c481c54b0?w=1200', height: 205, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height:205,color:navy)),
        Container(height:205, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft,end: Alignment.centerRight, colors: [navy.withValues(alpha:.92), navy.withValues(alpha:.12)]))),
        Positioned(left:20,top:22,right:20,child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('DISCOVER THE WORLD', style: TextStyle(color: Color(0xFFBDECE6),fontSize:10,letterSpacing:2,fontWeight:FontWeight.w900)),
          const SizedBox(height:10), const Text('Petualangan baru\nmenantimu.', style: TextStyle(color:Colors.white,fontSize:26,height:1.12,fontWeight:FontWeight.w900)),
          const SizedBox(height:12), const Text('Simpan tempat impian dan mulai rencanakan perjalananmu.', style: TextStyle(color:Colors.white,fontSize:11)),
          const SizedBox(height:13), FilledButton.icon(onPressed:()=>setState(()=>selectedTab=1), icon:const Icon(Icons.explore,size:16), label:const Text('Jelajahi sekarang'), style:FilledButton.styleFrom(backgroundColor:teal,foregroundColor:Colors.white,visualDensity:VisualDensity.compact)),
        ])),
      ])),
      const SizedBox(height:22),
      Row(children:[_statTile(Icons.bookmark_added_rounded,'${items.length}','Tersimpan'), const SizedBox(width:10), _statTile(Icons.map_rounded,'${items.where((e)=>'${e['status']}'.toLowerCase().contains('belum')).length}','Rencana'), const SizedBox(width:10), _statTile(Icons.check_circle_rounded,'${items.where((e)=>'${e['status']}'.toLowerCase().contains('sudah')).length}','Dikunjungi')]),
      const SizedBox(height:25),
      _sectionHeader('Kategori populer','Lihat semua',()=>setState(()=>selectedTab=1)),
      const SizedBox(height:13),
      SizedBox(height:88, child: ListView(scrollDirection:Axis.horizontal, children:[_categoryPill('🏝️','Pantai'),_categoryPill('⛰️','Gunung'),_categoryPill('🏙️','Kota'),_categoryPill('🌿','Alam'),_categoryPill('🏛️','Budaya')])),
      const SizedBox(height:24),
      _sectionHeader('Inspirasi perjalanan','Explore',()=>setState(()=>selectedTab=1)),
      const SizedBox(height:13),
      SizedBox(height:190, child: ListView(scrollDirection:Axis.horizontal, children:[
        _inspiration('Bali','Pulau Dewata','https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800','Pantai & budaya'),
        _inspiration('Raja Ampat','Papua Barat','https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?w=800','Surga bahari'),
        _inspiration('Bromo','Jawa Timur','https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800','Pegunungan'),
      ])),
      const SizedBox(height:24),
      _sectionHeader('Wishlist terbarumu','Lihat semua',()=>setState(()=>selectedTab=2)),
      const SizedBox(height:10),
      if(loading) const Center(child:Padding(padding:EdgeInsets.all(25),child:CircularProgressIndicator(color:teal)))
      else if(error!=null) _MessagePanel(icon:Icons.cloud_off_outlined,title:'Gagal memuat wishlist',message:error!,action:TextButton(onPressed:load,child:const Text('Coba lagi')))
      else if(items.isEmpty) _MessagePanel(icon:Icons.luggage_outlined,title:'Belum ada wishlist',message:'Tambahkan destinasi impianmu melalui tombol Tambah tempat.')
      else ...items.take(3).map((item){final x=Map<String,dynamic>.from(item);return _DestinationCard(item:x,onEdit:()=>openForm(x),onDelete:()=>remove(x));}),
    ]));

  Widget _wishlistContent() => ListView(padding:const EdgeInsets.fromLTRB(20,20,20,110),children:[
    const Text('Wishlist Saya',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:navy)),
    const SizedBox(height:5), Text('${items.length} destinasi yang ingin kamu kunjungi',style:const TextStyle(color:Colors.black54)),
    const SizedBox(height:18), TextField(onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(hintText:'Cari destinasi atau lokasi...',prefixIcon:Icon(Icons.search,color:teal))),
    const SizedBox(height:15),
    if(loading) const Center(child:Padding(padding:EdgeInsets.all(30),child:CircularProgressIndicator(color:teal)))
    else if(error!=null) _MessagePanel(icon:Icons.cloud_off,title:'Data belum tersedia',message:error!,action:TextButton(onPressed:load,child:const Text('Muat ulang')))
    else ...items.where((item){final x=Map<String,dynamic>.from(item);return '${x['destination']} ${x['location']}'.toLowerCase().contains(query.toLowerCase());}).map((item){final x=Map<String,dynamic>.from(item);return _DestinationCard(item:x,onEdit:()=>openForm(x),onDelete:()=>remove(x));}),
  ]);

  Widget _exploreContent() => ListView(padding:const EdgeInsets.fromLTRB(20,20,20,35),children:[
    const Text('Explore Destinasi',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:navy)),
    const SizedBox(height:5), const Text('Temukan inspirasi untuk perjalanan berikutnya.',style:TextStyle(color:Colors.black54)),
    const SizedBox(height:18),
    _exploreFeature('Bali','Indonesia','Pantai tropis, budaya, dan sunset yang memukau.','https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=1000','Pantai'),
    _exploreFeature('Raja Ampat','Papua Barat','Laut jernih dan gugusan pulau yang menakjubkan.','https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?w=1000','Alam'),
    _exploreFeature('Gunung Bromo','Jawa Timur','Nikmati lautan pasir dan matahari terbit.','https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1000','Pegunungan'),
    _exploreFeature('Yogyakarta','DI Yogyakarta','Wisata sejarah, kuliner, dan seni budaya.','https://images.unsplash.com/photo-1584810359583-96fc3448beaa?w=1000','Budaya'),
  ]);

  Widget _profileContent() => ListView(padding:const EdgeInsets.all(22),children:[
    const SizedBox(height:20), Center(child:Container(width:94,height:94,decoration:BoxDecoration(color:teal.withValues(alpha:.12),shape:BoxShape.circle),child:const Icon(Icons.person_rounded,size:55,color:teal))),
    const SizedBox(height:14), const Center(child:Text('Traveler',style:TextStyle(fontSize:23,fontWeight:FontWeight.w900,color:navy))),
    const Center(child:Text('Jelajahi dunia, satu perjalanan dalam satu waktu.',textAlign:TextAlign.center,style:TextStyle(color:Colors.black54))),
    const SizedBox(height:28), _profileOption(Icons.favorite_outline,'Total wishlist','${items.length} destinasi tersimpan'),
    _profileOption(Icons.cloud_done_outlined,'Sinkronisasi','Terhubung dengan server Travel Wishlist'),
    _profileOption(Icons.info_outline,'Tentang aplikasi','Travel Wishlist • Docker + MySQL'),
    const SizedBox(height:18), OutlinedButton.icon(onPressed:logout,icon:const Icon(Icons.logout),label:const Text('Keluar dari akun'),style:OutlinedButton.styleFrom(foregroundColor:Colors.red,padding:const EdgeInsets.all(15))),
  ]);

  Widget _statTile(IconData icon,String value,String label)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(vertical:15,horizontal:8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFFEAF0F4))),child:Column(children:[Icon(icon,color:teal,size:20),const SizedBox(height:7),Text(value,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900,color:navy)),Text(label,style:const TextStyle(fontSize:10,color:Colors.black54))])));
  Widget _sectionHeader(String title,String action,VoidCallback onTap)=>Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:navy)),TextButton(onPressed:onTap,child:Text(action,style:const TextStyle(color:teal,fontWeight:FontWeight.bold)))]);
  Widget _categoryPill(String emoji,String label)=>Container(width:75,margin:const EdgeInsets.only(right:10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17),border:Border.all(color:const Color(0xFFEAF0F4))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(emoji,style:const TextStyle(fontSize:25)),const SizedBox(height:5),Text(label,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:navy))]));
  Widget _inspiration(String name,String place,String image,String subtitle)=>Container(width:220,margin:const EdgeInsets.only(right:13),child:ClipRRect(borderRadius:BorderRadius.circular(20),child:Stack(fit:StackFit.expand,children:[Image.network(image,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:navy)),Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Color(0xDD102B40)]))),Positioned(left:14,bottom:13,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(subtitle,style:const TextStyle(color:Color(0xFFBDECE6),fontSize:10)),Text(name,style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),Text(place,style:const TextStyle(color:Colors.white70,fontSize:11))]))])));
  Widget _exploreFeature(String name,String place,String description,String image,String category)=>Container(margin:const EdgeInsets.only(bottom:17),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),boxShadow:[BoxShadow(color:navy.withValues(alpha:.06),blurRadius:15,offset:const Offset(0,6))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[ClipRRect(borderRadius:const BorderRadius.vertical(top:Radius.circular(22)),child:Image.network(image,height:155,width:double.infinity,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(height:155,color:navy))),Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(name,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:navy))),_Tag(label:category, color:teal.withValues(alpha:.14))]),Text(place,style:const TextStyle(color:teal,fontSize:12,fontWeight:FontWeight.bold)),const SizedBox(height:5),Text(description,style:const TextStyle(color:Colors.black54,fontSize:12)),const SizedBox(height:9),Align(alignment:Alignment.centerRight,child:FilledButton.icon(onPressed:()=>openForm({'destination':name,'location':place,'description':description,'priority':'Sedang','status':'Belum Dikunjungi'}),icon:const Icon(Icons.favorite_border,size:16),label:const Text('Simpan ke wishlist'),style:FilledButton.styleFrom(backgroundColor:teal,foregroundColor:Colors.white))) ]))]));
  Widget _profileOption(IconData icon,String title,String subtitle)=>ListTile(contentPadding:const EdgeInsets.symmetric(vertical:5),leading:CircleAvatar(backgroundColor:teal.withValues(alpha:.12),child:Icon(icon,color:teal)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold,color:navy)),subtitle:Text(subtitle,style:const TextStyle(fontSize:11,color:Colors.black54)));

}

class _MessagePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: const Color(0xFF9AAAB5)),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: navy, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF7C8A96), height: 1.4, fontSize: 13)),
            if (action != null) action!,
          ],
        ),
      );
}

class _DestinationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DestinationCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final visited = item['status'] == 'Sudah Dikunjungi';
    final location = '${item['location'] ?? 'Lokasi belum diisi'}';
    final category = '${item['category_name'] ?? 'Tanpa kategori'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.045),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: SizedBox(
                height: 72,
                width: 72,
                child: destinationImageFor(
                            '${item['destination'] ?? ''}', location) !=
                        null
                    ? Image.network(
                        destinationImageFor(
                            '${item['destination'] ?? ''}', location)!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFDDF4F0),
                          child: const Icon(Icons.landscape_outlined,
                              size: 34, color: teal),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFDDF4F0),
                        child: const Icon(Icons.landscape_outlined,
                            size: 34, color: teal),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item['destination'] ?? 'Tanpa nama'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: teal),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xFF7C8A96), fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      _Tag(label: category, color: const Color(0xFFE8F3F5)),
                      _Tag(
                        label: visited ? 'Sudah dikunjungi' : 'Belum dikunjungi',
                        color: visited
                            ? const Color(0xFFE4F4E9)
                            : const Color(0xFFFFF2DE),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
              icon: const Icon(Icons.more_vert, color: Color(0xFF82919C)),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                color: navy, fontSize: 10, fontWeight: FontWeight.w600)),
      );
}

class WishlistForm extends StatefulWidget {
  final Map? item;
  const WishlistForm({super.key, this.item});
  @override
  State<WishlistForm> createState() => _WishlistFormState();
}

class _WishlistFormState extends State<WishlistForm> {
  final destination = TextEditingController();
  final location = TextEditingController();
  final budget = TextEditingController();
  final description = TextEditingController();
  List categories = [];
  String priority = 'Sedang';
  String status = 'Belum Dikunjungi';
  int? categoryId;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final x = widget.item;
    if (x != null) {
      destination.text = '${x['destination'] ?? ''}';
      location.text = '${x['location'] ?? ''}';
      budget.text = '${x['estimated_budget'] ?? ''}';
      description.text = '${x['description'] ?? ''}';
      priority = x['priority'] ?? 'Sedang';
      status = x['status'] ?? 'Belum Dikunjungi';
      categoryId = int.tryParse('${x['category_id']}');
    }
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final r = await Api.get('/api/categories/index.php');
      if (mounted) setState(() => categories = r['data'] ?? []);
    } catch (_) {}
  }

  Future<void> save() async {
    if (destination.text.trim().isEmpty) {
      setState(() => error = 'Nama destinasi wajib diisi.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    final body = {
      'destination': destination.text.trim(),
      'location': location.text.trim(),
      'category_id': categoryId,
      'estimated_budget': budget.text.trim().isEmpty
          ? null
          : double.tryParse(budget.text.replaceAll(',', '')),
      'priority': priority,
      'description': description.text.trim(),
      'status': status,
    };
    try {
      if (widget.item == null) {
        await Api.post('/api/wishlists/index.php', body);
      } else {
        await Api.put(
            '/api/wishlists/update.php?id=${widget.item!['id']}', body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    destination.dispose();
    location.dispose();
    budget.dispose();
    description.dispose();
    super.dispose();
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 9, top: 17),
        child: Text(text,
            style: const TextStyle(
                color: navy, fontWeight: FontWeight.w800, fontSize: 14)),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.item == null ? 'Tambah Destinasi' : 'Edit Destinasi',
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF183B56), Color(0xFF17A398)]),
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_location_alt_outlined,
                      color: Colors.white, size: 35),
                  SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      'Rencanakan tempat yang ingin kamu jelajahi berikutnya.',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            _sectionLabel('Informasi destinasi'),
            TextField(
              controller: destination,
              decoration: const InputDecoration(
                labelText: 'Nama destinasi *',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: location,
              decoration: const InputDecoration(
                labelText: 'Lokasi / Kota',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            _sectionLabel('Kategori & anggaran'),
            DropdownButtonFormField<int?>(
              value: categoryId,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('Pilih kategori')),
                ...categories.map((c) => DropdownMenuItem<int?>(
                    value: int.parse('${c['id']}'),
                    child: Text('${c['name']}'))),
              ],
              onChanged: (v) => setState(() => categoryId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Estimasi budget (Rp)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            _sectionLabel('Rencana perjalanan'),
            DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(
                labelText: 'Prioritas',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ['Rendah', 'Sedang', 'Tinggi']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => priority = v ?? 'Sedang'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                labelText: 'Status kunjungan',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
              items: ['Belum Dikunjungi', 'Sudah Dikunjungi']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => status = v ?? 'Belum Dikunjungi'),
            ),
            _sectionLabel('Catatan tambahan'),
            TextField(
              controller: description,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi / catatan',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 53,
              child: FilledButton.icon(
                onPressed: busy ? null : save,
                style: FilledButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: Text(busy ? 'Menyimpan...' : 'Simpan destinasi',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
}
