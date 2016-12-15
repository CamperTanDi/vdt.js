Parser = require('../src/lib/parser')
Utils = require('../src/lib/utils')
Stringifier = require('../src/lib/stringifier')
should = require('should')

parser = new Parser
stringifier = new Stringifier

describe 'Stringifier', ->
    it 'Stringify attribute without value', ->
        source = """
        <input type="checkbox" checked />
        """
        stringifier.stringify(parser.parse(source)).should.eql("return h('input',{'type': 'checkbox', 'checked': null}, [])")

    it 'Stringifier attribute class', ->
        source = """
        <div class="aaa"></div>
        """

        stringifier.stringify(parser.parse(source)).should.eql("return h('div',{'className': 'aaa'}, [])")

    it 'Stringify text with quotes', ->
        source1 = """
        <input placeholder="a'a" />
        """
        source2 = """
        <div>{'a\\'a'}</div>
        """

        stringifier.stringify(parser.parse(source1)).should.eql("return h('input',{'placeholder': 'a\\'a'}, [])")
        stringifier.stringify(parser.parse(source2)).should.eql("return h('div',null, ['a\\'a'])")

    it 'Stringify without return', ->
        source = """
        <input type="checkbox" checked>
        """
        stringifier.stringify(parser.parse(source), false).should.eql("h('input',{'type': 'checkbox', 'checked': null}, [])")

    it 'Stringify widget', ->
        source = """
        <Page title="test" />
        """
        stringifier.stringify(parser.parse(source)).should.eql("return Page({'title': 'test', 'children': []}, widgets)")

    it 'Stringify widget with event', ->
        source = """
        <Page title="test" ev-change:size={function() {console.log(1)}}>
            <div>1</div>
            <div>2</div>
        </Page>
        """
        stringifier.stringify(parser.parse(source)).should.eql("return Page({'title': 'test', 'ev-change:size': function() {console.log(1)}, 'children': ['\\n    ', h('div',null, ['1']), '\\n    ', h('div',null, ['2']), '\\n']}, widgets)")

    it 'Stringify block directive', ->
        source = """
        <div>
            <b:content>
                <div>aaa</div>
            </b:content>
        </div>
        """

        stringifier.stringify(parser.parse(source)).should.eql("""
            return h('div',null, ['\\n    ', (_blocks.content = function(parent) {return ['\\n        ', h('div',null, ['aaa']), '\\n    '];}) && (__blocks.content = function(parent) {
            var self = this;
            return blocks.content ? blocks.content.call(this, function() {
            return _blocks.content.call(self, parent);
            }) : _blocks.content.call(this, parent);
            }) && __blocks.content.call(this), '\\n'])
            """)

    it 'Stringify vdt template directive', ->
        source = """
        <t:parent>
            <b:head>
                child head
            </b:head>
            <b:body>
                {parent()}
                <div>child body</div>
            </b:body>
        </t:parent>
        """

        stringifier.stringify(parser.parse(source)).should.eql("""
            return (function(blocks) {
            var _blocks = {}, __blocks = extend({}, blocks), _obj = null || {};
            if (_obj.hasOwnProperty("arguments")) { extend(_obj, _obj.arguments === null ? obj : _obj.arguments); delete _obj.arguments; }
            return parent.call(this, _obj, _Vdt, (_blocks.head = function(parent) {return ['\\n        child head\\n    '];}) && (__blocks.head = function(parent) {
            var self = this;
            return blocks.head ? blocks.head.call(this, function() {
            return _blocks.head.call(self, parent);
            }) : _blocks.head.call(this, parent);
            }) && (_blocks.body = function(parent) {return ['\\n        ', parent(), '\\n        ', h('div',null, ['child body']), '\\n    '];}) && (__blocks.body = function(parent) {
            var self = this;
            return blocks.body ? blocks.body.call(this, function() {
            return _blocks.body.call(self, parent);
            }) : _blocks.body.call(this, parent);
            }) && __blocks)}).call(this, blocks)
            """)

    it 'Stringify vdt template with js', ->
        source = """
        var a = 1;
        <t:base>
            <b:body>good</b:body>
        </t:base>
        """

        stringifier.stringify(parser.parse(source)).should.eql("""
            var a = 1;
            return (function(blocks) {
            var _blocks = {}, __blocks = extend({}, blocks), _obj = null || {};
            if (_obj.hasOwnProperty("arguments")) { extend(_obj, _obj.arguments === null ? obj : _obj.arguments); delete _obj.arguments; }
            return base.call(this, _obj, _Vdt, (_blocks.body = function(parent) {return ['good'];}) && (__blocks.body = function(parent) {
            var self = this;
            return blocks.body ? blocks.body.call(this, function() {
            return _blocks.body.call(self, parent);
            }) : _blocks.body.call(this, parent);
            }) && __blocks)}).call(this, blocks)
            """)

    it 'Stringify empty template directive', ->
        source = """
        <t:base />
        """

        stringifier.stringify(parser.parse(source)).should.eql("""
            return (function(blocks) {
            var _blocks = {}, __blocks = extend({}, blocks), _obj = null || {};
            if (_obj.hasOwnProperty("arguments")) { extend(_obj, _obj.arguments === null ? obj : _obj.arguments); delete _obj.arguments; }
            return base.call(this, _obj, _Vdt, __blocks)}).call(this, blocks)
            """)

    it 'Stringify nested t:directive', ->
        source = """
        <t:base1>
            <b:body>
                <t:base2>
                    <b:body>base2 body</b:body>
                </t:base2>
            </b:body>
        </t:base1>
        """

        stringifier.stringify(parser.parse(source)).should.eql("""
            return (function(blocks) {
            var _blocks = {}, __blocks = extend({}, blocks), _obj = null || {};
            if (_obj.hasOwnProperty("arguments")) { extend(_obj, _obj.arguments === null ? obj : _obj.arguments); delete _obj.arguments; }
            return base1.call(this, _obj, _Vdt, (_blocks.body = function(parent) {return ['\\n        ', (function(blocks) {
            var _blocks = {}, __blocks = extend({}, blocks), _obj = null || {};
            if (_obj.hasOwnProperty("arguments")) { extend(_obj, _obj.arguments === null ? obj : _obj.arguments); delete _obj.arguments; }
            return base2.call(this, _obj, _Vdt, (_blocks.body = function(parent) {return ['base2 body'];}) && (__blocks.body = function(parent) {
            var self = this;
            return blocks.body ? blocks.body.call(this, function() {
            return _blocks.body.call(self, parent);
            }) : _blocks.body.call(this, parent);
            }) && __blocks)}).call(this, {}), '\\n    '];}) && (__blocks.body = function(parent) {
            var self = this;
            return blocks.body ? blocks.body.call(this, function() {
            return _blocks.body.call(self, parent);
            }) : _blocks.body.call(this, parent);
            }) && __blocks)}).call(this, blocks)
            """)

    it 'Set delimiters to ["{{", "}}"]', ->
        source = """
        <div class={{ className }} style={{ {width: '100px'} }}>
            {test} {{ test ? "test" : '{test}' }}
        </div>
        """
        Utils.setDelimiters(['{{', '}}'])

        stringifier.stringify(parser.parse(source)).should.eql("""return h('div',{'className': _Vdt.utils.className( className ), 'style':  {width: '100px'} }, ['\\n    {test} ',  test ? "test" : '{test}' , '\\n'])""")
        Utils.setDelimiters(['{', '}'])

    it 'Set Delimiters to ["{%", "%}"]', ->
        source = """
        <div class={% className %} style={% {width: '100px'} %}>
            {test} {% test ? "test" : '{test}' %}
        </div>
        """
        Utils.setDelimiters(['{%', '%}'])

        stringifier.stringify(parser.parse(source)).should.eql("""return h('div',{'className': _Vdt.utils.className( className ), 'style':  {width: '100px'} }, ['\\n    {test} ',  test ? "test" : '{test}' , '\\n'])""")
        Utils.setDelimiters(['{', '}'])

    it '< in textNode', ->
        source = """
        <div>a < b ? a : b; a <2? a : b</div>
        """
        stringifier.stringify(parser.parse(source)).should.eql("return h('div',null, ['a < b ? a : b; a <2? a : b'])")

    it 'Stringify script content', ->
        source = """
        <script type="text/javascript">
            var a = 1;
            console.log(a);
            if (a < 2) {
                console.log('less than {{ a < 2 'a' : 'b' }}');
            }
        </script>
        """
        Utils.setDelimiters(['{{', '}}'])
        stringifier.stringify(parser.parse(source)).should.eql("""return h('script',{'type': 'text/javascript', 'innerHTML': '\\n    var a = 1;\\n    console.log(a);\\n    if (a < 2) {\\n        console.log(\\'less than '+( a < 2 'a' : 'b' )+'\\');\\n    }\\n'}, [])""")
        Utils.setDelimiters(['{', '}'])

    it 'Stringify html comment', ->
        source = """
        <div>
            <!-- this is a html comment -->
            test
        </div>
        """

        stringifier.stringify(parser.parse(source)).should.eql """return h('div',null, ['\\n    ', h.c(' this is a html comment '), '\\n    test\\n'])"""

    it 'Stringify directive', ->
        source = """
        <div v-if={true} class="test" v-for={data} v-for-key="index">show</div>
        """

        stringifier.stringify(parser.parse(source)).should.eql """
        return _Vdt.utils.map(data, function(value, index) {
        return true ? h('div',{'className': 'test'}, ['show']) : undefined;
        }, this)
        """

    it 'Stringify directive in Widget', ->
        source = """
        <Div v-if={true} class="test" v-for={data} v-for-key="index">show</Div>
        """
        stringifier.stringify(parser.parse(source)).should.eql """
        return _Vdt.utils.map(data, function(value, index) {
        return true ? Div({'className': 'test', 'children': ['show']}, widgets) : undefined;
        }, this)
        """

    it 'Stringify v-if v-else in Widget', ->
        source = """
        <div>
            <div v-if={test === 1}></div>
            <Div v-else-if={test === 2}></Div>
            <div v-else-if={test === 3}></div>
            <Div v-else></Div>
        </div>
        """

        stringifier.stringify(parser.parse(source)).should.eql """
        return h('div',null, ['\\n    ', test === 1 ? h('div',null, []) : test === 2 ? Div({'children': []}, widgets) : test === 3 ? h('div',null, []) : Div({'children': []}, widgets), '\\n'])
        """

    it 'Stringify object className', ->
        source = """
        <div class={{a: true, 'b c': 1}}><i class="{a: 1}"></i></div>
        """

        stringifier.stringify(parser.parse(source)).should.eql "return h('div',{'className': _Vdt.utils.className({a: true, 'b c': 1})}, [h('i',{'className': '{a: 1}'}, [])])"

    it 'Stringify complex javascript code in <script></script>', ->
        source = """
        <script>
            var a;

            function aa() {
                var msg;
                msg = '<form onsubmit="return setPassword();"';
                msg += '  style="margin-bottom: 0px">';
                msg += '<input type=password size=10 id="password_input">';
                msg += '</form>';
            }

            if (a<1) { console.log(a) }

            var b = "{{ a }}";
        </script>
        """

        stringifier.stringify(parser.parse(source, {delimiters: ['{{', '}}']})).should.eql "return h('script',{'innerHTML': '\\n    var a;\\n\\n    function aa() {\\n        var msg;\\n        msg = \\'<form onsubmit=\\\"return setPassword();\\\"\\';\\n        msg += \\'  style=\\\"margin-bottom: 0px\\\">\\';\\n        msg += \\'<input type=password size=10 id=\\\"password_input\\\">\\';\\n        msg += \\'</form>\\';\\n    }\\n\\n    if (a<1) { console.log(a) }\\n\\n    var b = \\\"'+( a )+'\\\";\\n'}, [])"

