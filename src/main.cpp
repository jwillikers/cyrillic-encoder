#include <QApplication>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QLabel>
#include <QMainWindow>
#include <QMessageBox>
#include <QObject>
#include <QPushButton>
#include <QTableWidget>
#include <QTextEdit>
#include <QVBoxLayout>
#include <boost/range/adaptors.hpp>
#include <cyrillic-encoder/encode.hpp>

int main(int argc, char *argv[]) {
  QCoreApplication::setAttribute(
      Qt::ApplicationAttribute::AA_EnableHighDpiScaling);

  QApplication app(argc, argv);
  QCoreApplication::setApplicationName(QObject::tr("Cyrillic Encoder"));
  QCoreApplication::setApplicationVersion(QObject::tr("0.0.1"));

  QMainWindow main_window;

  QWidget window(&main_window);
  QVBoxLayout window_layout(&window);
  main_window.setCentralWidget(&window);

  QWidget encode_area = QWidget(&window);
  window_layout.addWidget(&encode_area);
  QHBoxLayout encode_area_layout(&encode_area);
  QVBoxLayout encode_box(&encode_area);
  encode_area_layout.addLayout(&encode_box);

  QTextEdit input(&encode_area);
  input.setAccessibleName(QObject::tr("Input"));
  input.setAccessibleDescription(
      QObject::tr("This text is converted to Cyrillic"));
  input.setToolTip(
      QObject::tr("Alphanumeric characters to encode in Cyrillic"));
  input.setPlaceholderText(QObject::tr("Latin text to encode"));
  encode_box.addWidget(&input);

  QTextEdit encoded(&encode_area);
  encoded.setAccessibleName(QObject::tr("Encoded"));
  encoded.setReadOnly(true);
  encoded.setAccessibleDescription(
      QObject::tr("This is the text converted to Cyrillic"));
  encoded.setToolTip(QObject::tr("Encoded Cyrillic text"));
  encoded.setPlaceholderText(QObject::tr("Encoded Cyrillic text"));
  encode_box.addWidget(&encoded);

  QObject::connect(&input, &QTextEdit::textChanged, &encoded, [&]() {
    encoded.setText(
        QString(std::string_view(
                    cyr_enc::encode_string(input.toPlainText().toStdString()))
                    .data()));
  });

  QWidget decode_table_widget(&encode_area);
  decode_table_widget.setAccessibleName(QObject::tr("Decode Table"));
  decode_table_widget.setToolTip(
      QObject::tr("Latin to Cyrillic conversion table"));
  QVBoxLayout decode_table_layout(&decode_table_widget);
  QLabel decode_table_label(QObject::tr("Decode Table"), &decode_table_widget);
  decode_table_layout.addWidget(&decode_table_label, 0,
                                Qt::AlignmentFlag::AlignCenter);
  QTableWidget decode_table(cyr_enc::num_alphanumeric, 2, &encode_area);
  QStringList headers;
  headers.append(QObject::tr("Latin"));
  headers.append(QObject::tr("Cyrillic"));
  decode_table.setHorizontalHeaderLabels(headers);
  decode_table.verticalHeader()->setVisible(false);
  for (auto const &pair :
       cyr_enc::sample_conversion_table | boost::adaptors::indexed()) {
    auto *latin = new QTableWidgetItem(QString(std::get<0>(pair.value())));
    Qt::ItemFlags flags;
    flags.setFlag(Qt::ItemFlag::ItemIsEditable, false);
    latin->setFlags(flags);
    decode_table.setItem(pair.index(), 0, latin);
    auto *cyrillic =
        new QTableWidgetItem(QString(std::get<1>(pair.value()).data()));
    cyrillic->setFlags(flags);
    decode_table.setItem(pair.index(), 1, cyrillic);
  }
  decode_table_layout.addWidget(&decode_table);
  encode_area_layout.addWidget(&decode_table_widget);

  QWidget button_bar(&encode_area);
  button_bar.setLayout(new QHBoxLayout);
  QPushButton about(QObject::tr("About"), &button_bar);
  about.setToolTip(QObject::tr("About Cyrillic Encoder"));
  QObject::connect(&about, &QPushButton::clicked, &app, [&]() {
    QMessageBox::about(
        &encode_area, QObject::tr("About Cyrillic Encoder"),
        QObject::tr("This application encodes alphanumeric characters as "
                    "arbitrary Cyrillic characters."));
  });
  button_bar.layout()->addWidget(&about);
  QPushButton about_qt(QObject::tr("About Qt"), &button_bar);
  about_qt.setToolTip(QObject::tr("About the Qt framework"));
  QObject::connect(&about_qt, &QPushButton::clicked, &app,
                   &QApplication::aboutQt);
  button_bar.layout()->addWidget(&about_qt);
  QPushButton close(QObject::tr("Close"), &button_bar);
  close.setToolTip(QObject::tr("Quit the application"));
  QObject::connect(&close, &QPushButton::clicked, &QCoreApplication::quit);
  button_bar.layout()->addWidget(&close);
  window_layout.addWidget(&button_bar, 0, Qt::AlignmentFlag::AlignRight);

  main_window.show();
  return app.exec();
}
