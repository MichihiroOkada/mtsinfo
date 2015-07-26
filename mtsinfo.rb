# encoding: UTF-8
require 'gtk2'
require './config'

load './mtsparse.rb'
load './history.rb'
load './log.rb'

# read config file
$log = Log.new($config[:logoutput])

class MyTreeView < Gtk::TreeView
  # 列を指定するときに使う定数
 
  COL_PATH = 0
  COL_DATE = 1

  #=== 初期化
  def initialize
    # 親クラスのinitializeを実行
    super
    # [1]リストに表示するデータモデルを作成(引数には列に詰めたいクラスを順に指定する)
    liststore = Gtk::ListStore.new(String, String)
    # [2]TreeViewとデータモデルを関連付ける
    set_model(liststore)
   
    # [3]セルの描画設定を用意する(ここでは文字列用)
    renderer = Gtk::CellRendererText.new
    @col_path = Gtk::TreeViewColumn.new("Path", renderer, :text => COL_PATH)
    append_column(@col_path)
   
    @col_date = Gtk::TreeViewColumn.new("Datetime", renderer, :text => COL_DATE)
    append_column(@col_date)

  end

  def setPathColumnName(path)
    @col_path.title = path
  end

  def initlist
    model.clear
  end

  def setlist(items)
    items.each do |item|
      iter = model.append
      iter[COL_PATH] = item.path
      iter[COL_DATE] = item.datetime
    end
  end
end

def start_mtsinfo
  window = Gtk::Window.new("Menu Bar w/submenus (1)")
  window.signal_connect("destroy") {
    Gtk.main_quit
  }
  window.title="MTS Info List"
  window.set_default_size(640,480)
  #window.add(lbl)
  
  # ビューを作成
  treeview = MyTreeView.new
  
  scrolled_window = Gtk::ScrolledWindow.new(nil, nil)
  scrolled_window.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
  
  #Gtk::VScrollbar.new(adjustment = nil)
  scrolled_window.add(treeview)
  
  ####################### menu
  menu_bar = Gtk::MenuBar.new
  file_item = Gtk::MenuItem.new('File')
  file_item.show
  file_menu = Gtk::Menu.new
  open_menu = Gtk::MenuItem.new('Open')
  open_menu.show
  quit_menu = Gtk::MenuItem.new('Quit')
  quit_menu.show
  file_menu.add open_menu
  file_menu.add quit_menu
  file_item.set_submenu file_menu
  menu_bar.append file_item
  menu_bar.show
  
  open_menu.signal_connect("activate") {
    fs = Gtk::FileSelection.new("Please select a directory.")

    if($config[:save_file].length > 0)
      historyinfo = History.new($config[:save_file])
      historyinfo.load
      fs.filename = historyinfo.get_path
    end

    if fs.filename
      $log.debuglog("Default file path is [" + fs.filename + "]")
    else
      fs.filename = $config[:default_dir]
    end
  
    fs.ok_button.signal_connect("clicked") do
      treeview.initlist
      treeview.setPathColumnName("Path(#{fs.filename})")
  
      historyinfo.set_path("#{fs.filename}")
      historyinfo.save
  
      $log.debuglog("Selected file path is [" + "#{fs.filename}" + "]")
      mtsinfo = MtsInfo.new
      mtsinfo.get_mtsinfo("#{fs.filename}", $config[ :show_basedir ])
      #mtsinfo.get_mtsinfo("#{fs.filename}", true)
      treeview.setlist(mtsinfo.mtsinfolist)
      fs.hide
    end
  
    #CANCEL
    fs.cancel_button.signal_connect("clicked") do
      fs.hide
    end
   
    fs.show_all
  }
  
  quit_menu.signal_connect("activate") {
    Gtk.main_quit
  }
  #######################
  
  vbox = Gtk::VBox.new(false, 0)
  vbox.pack_start menu_bar, false, false, 0
  vbox.pack_start scrolled_window, true, true, 0
  vbox.show
  
  #window.add(menu_bar)
  
  # 配置と実行
  #window.add(scrolled_window)
  window.add(vbox)
  #window.add(treeview)
  window.show_all
  
  Gtk.main
end

if $0 == __FILE__ 
  start_mtsinfo
end
