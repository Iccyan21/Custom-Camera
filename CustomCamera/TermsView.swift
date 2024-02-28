//
//  TermsView.swift
//  CustomCamera
//
//  Created by 水原　樹 on 2024/02/25.
//

import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            LazyVStack{
                Text("この利用規約（以下，「本規約」といいます。）は、開発者がこのウェブサイト上で提供するサービス（以下，「本サービス」といいます。）の利用条件を定めるものです。登録ユーザーの皆さま（以下，「ユーザー」といいます。）には，本規約に従って，本サービスをご利用いただきます。\n\n第1条\n\n（適用）\n本規約は，ユーザーと開発者との間の本サービスの利用に関わる一切の関係に適用されるものとします。開発者は本サービスに関し，本規約のほか，ご利用にあたってのルール等，各種の定め（以下，「個別規定」といいます。）をすることがあります。これら個別規定はその名称のいかんに関わらず，本規約の一部を構成するものとします。本規約の規定が前条の個別規定の規定と矛盾する場合には，個別規定において特段の定めなき限り，個別規定の規定が優先されるものとします。\n\n第2条\n\n（利用登録）本サービスにおいては，登録希望者が本規約に同意の上，開発者の定める方法によって利用登録を申請し，開発者がこれを承認することによって，利用登録が完了するものとします。開発者は，利用登録の申請者に以下の事由があると判断した場合，利用登録の申請を承認しないことがあり，その理由については一切の開示義務を負わないものとします。利用登録の申請に際して虚偽の事項を届け出た場合本規約に違反したことがある者からの申請である場合その他，開発者が利用登録を相当でないと判断した場合\n\n第3条\n\n（ユーザーIDおよびパスワードの管理）ユーザーは，自己の責任において，本サービスのユーザーIDおよびパスワードを適切に管理するものとします。ユーザーは，いかなる場合にも，ユーザーIDおよびパスワードを第三者に譲渡または貸与し，もしくは第三者と共用することはできません。開発者は，ユーザーIDとパスワードの組み合わせが登録情報と一致してログインされた場合には，そのユーザーIDを登録しているユーザー自身による利用とみなします。ユーザーID及びパスワードが第三者によって使用されたことによって生じた損害は，開発者に故意又は重大な過失がある場合を除き，開発者は一切の責任を負わないものとします。\n\n第4条\n\n（利用料金および支払方法）ユーザーは，本サービスの有料部分の対価として，開発者が別途定め，本ウェブサイトに表示する利用料金を，開発者が指定する方法により支払うものとします。ユーザーが利用料金の支払を遅滞した場合には，ユーザーは年14．6％の割合による遅延損害金を支払うものとします。\n\n第5条\n\n（禁止事項）ユーザーは，本サービスの利用にあたり，以下の行為をしてはなりません。\n\n法令または公序良俗に違反する行為犯罪行為に関連する行為本サービスの内容等，\n\n本サービスに含まれる著作権，\n\n商標権ほか知的財産権を侵害する行為開発者，\n\nほかのユーザー，またはその他第三者のサーバーまたはネットワークの機能を破壊したり，妨害したりする行為\n\n本サービスによって得られた情報を商業的に利用する行為\n\n開発者のサービスの運営を妨害するおそれのある行為\n\n不正アクセスをし，またはこれを試みる行為\n\n他のユーザーに関する個人情報等を収集または蓄積する行為\n\n不正な目的を持って本サービスを利用する行為\n\n本サービスの他のユーザーまたはその他の第三者に不利益，損害，不快感を与える行為\n\n他のユーザーに成りすます行為\n\n開発者が許諾しない本サービス上での宣伝，広告，勧誘，または営業行為\n\n面識のない異性との出会いを目的とした行為\n\n開発者のサービスに関連して，反社会的勢力に対して直接または間接に利益を供与する行為\n\nその他，開発者が不適切と判断する行為\n\n第7条（利用制限および登録抹消）\n\n開発者は，ユーザーが以下のいずれかに該当する場合には，事前の通知なく，ユーザーに対して，本サービスの全部もしくは一部の利用を制限し，またはユーザーとしての登録を抹消することができるものとします。\n\n本規約のいずれかの条項に違反した場合\n\n登録事項に虚偽の事実があることが判明した場合\n\n料金等の支払債務の不履行があった場合\n\n開発者からの連絡に対し，一定期間返答がない場合\n\n本サービスについて，最終の利用から一定期間利用がない場合\n\nその他，開発者が本サービスの利用を適当でないと判断した場合\n\n開発者は，本条に基づき開発者が行った行為によりユーザーに生じた損害について，一切の責任を負いません。\n\n第8条（退会）\n\nユーザーは，開発者の定める退会手続により，本サービスから退会できるものとします。\n\n第9条（保証の否認および免責事項）\n\n開発者は，本サービスに事実上または法律上の瑕疵（安全性，信頼性，正確性，完全性，有効性，特定の目的への適合性，セキュリティなどに関する欠陥，エラーやバグ，権利侵害などを含みます。）がないことを明示的にも黙示的にも保証しておりません。\n\n開発者は，本サービスに起因してユーザーに生じたあらゆる損害について、開発者の故意又は重過失による場合を除き、一切の責任を負いません。ただし，本サービスに関する開発者とユーザーとの間の契約（本規約を含みます。）が消費者契約法に定める消費者契約となる場合，この免責規定は適用されません。\n\n前項ただし書に定める場合であっても，開発者は，開発者の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害のうち特別な事情から生じた損害（開発者またはユーザーが損害発生につき予見し，または予見し得た場合を含みます。）について一切の責任を負いません。また，開発者の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害の賠償は，ユーザーから当該損害が発生した月に受領した利用料の額を上限とします。\n\n開発者は，本サービスに関して，ユーザーと他のユーザーまたは第三者との間において生じた取引，連絡または紛争等について一切責任を負いません。\n\n第10条（サービス内容の変更等）\n\n開発者は，ユーザーへの事前の告知をもって、本サービスの内容を変更、追加または廃止することがあり、ユーザーはこれを承諾するものとします。\n\n第11条（利用規約の変更）\n\n開発者は以下の場合には、ユーザーの個別の同意を要せず、本規約を変更することができるものとします。\n\n本規約の変更がユーザーの一般の利益に適合するとき。\n\n本規約の変更が本サービス利用契約の目的に反せず、かつ、変更の必要性、変更後の内容の相当性その他の変更に係る事情に照らして合理的なものであるとき。\n\n開発者はユーザーに対し、前項による本規約の変更にあたり、事前に、本規約を変更する旨及び変更後の本規約の内容並びにその効力発生時期を通知します。\n\n第12条（個人情報の取扱い）\n\n開発者は，本サービスの利用によって取得する個人情報については，開発者「プライバシーポリシー」に従い適切に取り扱うものとします。\n\n第12条（個人情報の取扱い）\n\n開発者は，本サービスの利用によって取得する個人情報については，開発者「プライバシーポリシー」に従い適切に取り扱うものとします。\n\n第13条（通知または連絡）\n\nユーザーと開発者との間の通知または連絡は，開発者の定める方法によって行うものとします。開発者は,ユーザーから,開発者が別途定める方式に従った変更届け出がない限り,現在登録されている連絡先が有効なものとみなして当該連絡先へ通知または連絡を行い,これらは,発信時にユーザーへ到達したものとみなします。\n\n第14条（権利義務の譲渡の禁止）\n\nユーザーは，開発者の書面による事前の承諾なく，利用契約上の地位または本規約に基づく権利もしくは義務を第三者に譲渡し，または担保に供することはできません。\n\n第15条（準拠法・裁判管轄）\n\n本規約の解釈にあたっては，日本法を準拠法とします。\n\n本サービスに関して紛争が生じた場合には，開発者の本店所在地を管轄する裁判所を専属的合意管轄とします。")
          
            }
                .padding()
        }
        .navigationTitle("利用規約")
    }
}

#Preview {
    TermsView()
}
