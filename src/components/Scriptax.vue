<template>
    <div>
        <h2>Scriptax</h2>
        <p class="mb-2 text-muted">Control Flow, Scoping, and Automation.</p>
        <p class="lead">For more help, please see the Apitax <a
                href="https://github.com/ShawnClake/Apitax/blob/master/README.md">documentation</a>.</p>

        <hr>

        <section>
            <div class="row">
                <div class="col">
                    <p class="lead">Using Account: <b><span id="accountSlot">{{username}}</span></b></p>
                    <p class="mb-2 text-muted">This utility prints the complete response to the browser dev-tools
                        console in JSON format. Press F12 in chrome to view</p>
                    <hr>
                    <div class="row">

                        <div class="col">
                            <p class="lead">Flags</p>
                            <div class="form-group" style="padding-left:15px;">
                                <div class="row">
                                    <div class="col">
                                        <input type="checkbox" id="debug" value="Debug" v-on:change="optionsChange"
                                               v-model="globalOptions">
                                        <label for="debug">Debug</label>
                                        <small id="debugHelp" class="form-text text-muted">Outputs verbose, detailed
                                            information
                                            about the request.
                                        </small>
                                    </div>
                                    <div class="col">
                                        <input type="checkbox" id="sensitive" value="Sensitive"
                                               v-on:change="optionsChange" v-model="globalOptions">
                                        <label for="sensitive">Sensitive</label>
                                        <small id="sensitiveHelp" class="form-text text-muted">Prevents post data sent
                                            with the
                                            request from being output/logged.
                                        </small>

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <hr>

        <section>
            <div class="row" style="padding-right:15px;">
                <div class="col-8">
                    <p class="lead">Available Scripts</p>
                </div>
                <div class="col-4">
                    <button v-on:click="openScriptCreator($event.target)" style="margin-left:10px;"
                            class="btn btn-sm btn-primary float-right"><i class="fas fa-plus"></i></button>
                    <button v-on:click="getScriptsList()" class="btn btn-sm btn-success float-right"><i
                            class="fas fa-sync-alt"></i></button>
                </div>
            </div>

            <div class="row">
                <div class="col">
                    <b-alert :show="alert.dismiss.countdown"
                             dismissible
                             :variant="alert.style"
                             @dismissed="alert.dismiss.countdown=0"
                             @dismiss-count-down="countDownChanged">
                        <p>{{alert.text}}</p>
                        <b-progress :variant="alert.style"
                                    :max="alert.dismiss.secs"
                                    :value="alert.dismiss.countdown"
                                    height="4px">
                        </b-progress>
                    </b-alert>
                </div>
            </div>

            <div class="row" style="padding-left:15px;padding-right:15px;">
                <div class="col">
                    <b-form-input v-model="filter" placeholder="Type to Filter the table (Search)"/>

                </div>
            </div>

            <div class="row" style="padding-left:15px;padding-right:15px;margin-top:15px;">
                <div class="col">
                    <b-table hover striped small @filtered="onFiltered" :filter="filter" :fields="fields"
                             :sort-by.sync="sortBy" :sort-desc.sync="sortDesc" :current-page="currentPage"
                             :per-page="perPage" :items="scripts">
                        <!---<span slot="options" slot-scope="data" v-html="data.value"> -->
                        <template slot="options" slot-scope="data">
                            <b-btn size="sm" @click.stop="doScript(data.value,$event.target)" class="btn-success"><i
                                    class="fas fa-play"></i></b-btn>
                            <b-btn size="sm" @click.stop="viewScript(data.value,$event.target)" class="btn-primary"><i
                                    class="fas fa-pencil-alt"></i> / <i class="fas fa-eye"></i></b-btn>
                        </template>
                        <!--- </span>--->
                    </b-table>
                    <b-pagination align="center" size="md" :total-rows="totalRows" v-model="currentPage"
                                  :per-page="perPage">
                    </b-pagination>
                </div>
            </div>


        </section>

        <hr>

        <section v-if="response!=''" style="//background-color:rgba(0,0,0,0.02)">
            <div class="row">
                <div class="col">
                    <p class="lead">Response: </p>
                    <p>
                        <tree-view :options="{maxDepth: 1, rootObjectKey: 'response'}" :data="response"></tree-view>
                    </p>
                </div>
            </div>
        </section>


        <b-modal ref="scriptCodeModal" hide-footer centered title="Code Editor">
            <div class="d-block">
                <h4 style="text-transform:capitalize;">{{selectedScript.name}}</h4>
                <div class="row">
                    <div class="col">
                        <codemirror ref="scriptCodeMirror" v-model="selectedScript.code" :options="cmOptions"
                                    @ready="onCmReady"></codemirror>
                    </div>
                </div>
                <hr>
                <div class="row">
                    <div class="col">
                        <router-link class="float-left align-middle" to="/scriptax/edit">Advanced Edit</router-link>
                        <button v-on:click="saveCode(selectedScript.label,false,$event.target)"
                                class="btn btn-success float-right">Save
                        </button>
                        <button v-on:click="saveCode(selectedScript.label,true,$event.target)"
                                style="margin-right:15px;" class="btn btn-success float-right">Save and Run
                        </button>
                    </div>
                </div>
            </div>
        </b-modal>

        <b-modal ref="scriptCreatorModal" hide-footer centered title="Script Creator">
            <div class="d-block">
                <label class="lead" for="scriptCreatorName"><strong>Script Name</strong></label>

                <input type="text" v-model="creator.name" placeholder="Type a name" class="form-control"
                       id="scriptCreatorName">

                <div class="row" style="margin-top:15px;">
                    <div class="col">
                        <codemirror ref="scriptCreatorMirror" v-model="creator.code" :options="cmOptions"></codemirror>
                    </div>
                </div>
                <hr>
                <div class="row">
                    <div class="col">
                        <button v-on:click="createCode(creator.name,false,$event.target)"
                                class="btn btn-success float-right">Create
                        </button>
                    </div>
                </div>
            </div>
        </b-modal>

        <b-modal ref="scriptParamsModal" hide-footer centered title="Parameters are required to run this script">
            <div class="d-block">
                <h4 style="text-transform:capitalize;">{{selectedScript.name}}</h4>
                <div class="row">
                    <div class="col">


                        <div v-for="scriptparam in data.params" class="row" style="margin-top:15px;">

                            <div class="col-4">
                                <label style="text-transform:capitalize;" class="lead" :for="scriptparam.id"><strong>{{scriptparam.label}}:</strong></label>
                            </div>
                            <div class="col-8">
                                <input type="text" v-model="scriptparam.value" placeholder="Type a value here"
                                       class="form-control"
                                       :id="scriptparam.id">

                            </div>
                        </div>


                    </div>
                </div>
                <hr>
                <div class="row">
                    <div class="col">
                        <button v-on:click="executeScript(selectedScript.label,$event.target)"
                                class="btn btn-success float-right">Execute
                        </button>
                    </div>
                </div>
            </div>
        </b-modal>

    </div>
</template>


<script>
    import * as apitax from '@apitax/api-client'

    function capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    export default {
        data: function () {
            return {
                sortBy: 'label',
                sortDesc: false,
                errors: [],
                response: '',
                selectedScript: {label: '', code: '', name: ''},
                creator: {label: '', code: '', name: ''},
                data: {params: {}},
                codeMirror: {},
                timer: '',
                alert: {text: '', style: 'success', dismiss: {secs: 10, countdown: 0}},
                globals: {debug: true, sensitive: false},
                globalOptions: [],
                cmOptions: {
                    tabSize: 4,
                    mode: 'text/javascript',
                    lineNumbers: true,
                    line: true,
                },
                scripts: [],
                currentPage: 1,
                perPage: 10,
                totalRows: 0,
                filter: null,
                fields: [{key: 'options', label: '', tdClass: 'align-middle'}, {
                    key: 'label',
                    label: 'Script Name',
                    tdClass: 'align-middle',
                    sortable: true
                }, {key: 'relative-path', label: 'Script File', tdClass: 'align-middle'},],
                scriptstemp: [{
                    text: 'This is <i>escaped</i> content',
                    html: 'This is <i>raw <strong>HTML</strong></i> <span style="color:red">content</span>'
                }],

            }
        },

        methods: {
            optionsChange: function () {
                if (this.globalOptions.includes('Sensitive'))
                    this.globals.sensitive = true;
                else
                    this.globals.sensitive = false;

                if (this.globalOptions.includes('Debug'))
                    this.globals.debug = true;
                else
                    this.globals.debug = false;

            },
            saveCode: function (scriptName, execute, event) {
                console.log('SAVING: ' + scriptName);
                apitax.saveScript(this, function (context, response) {
                        console.log(response);
                        context.$refs.scriptCodeModal.hide();
                        context.showAlert('The script was saved.', 'success');
                        if (execute) {
                            context.doScript(scriptName);
                        }

                    },
                    {'script': {'name': scriptName, 'content': this.selectedScript.code}});
            },
            createCode: function (scriptName, execute, event) {
                console.log('CREATING: ' + scriptName);
                apitax.createScript(this, function (context, response) {
                        console.log(response);
                        context.$refs.scriptCreatorModal.hide();
                        context.showAlert('The script was created.', 'success');
                        context.getScriptsList();
                    },
                    {'script': {'name': scriptName, 'content': this.creator.code}});
            },
            codeChange: function () {
                this.codeMirror.refresh()
            },

            executeScript: function (scriptName, event) {

                this.$refs.scriptParamsModal.hide();

                var params = {};

                if (!(Object.keys(this.data.params).length === 0 && this.data.params.constructor === Object)) {
                    Object.keys(this.data.params).forEach(key => {
                        params[this.data.params[key]['label']] = this.data.params[key]['value'];
                    });
                }

                let command = 'script ' + scriptName;
                apitax.request(this, function (context, response) {
                    console.log(response);
                    context.response = response.data;
                    if (response.data.status > 299) {

                        context.showAlert(response.data.message, 'danger');
                    } else {
                        context.showAlert("Request was executed successfully", 'success');
                    }

                }, {
                    'command': {'command': command, 'parameters': params, 'options': {
                        		'debug': this.globals.debug,
                        		'sensitive': this.globals.sensitive,
                    		},
                    },
										'auth': {
												'api_token': apitax.getApiToken(),
										},
                }, null);

            },

            doScript: function (scriptName, event) {

                this.$store.commit('useScript', {script: scriptName});

                this.data.params = {};

                apitax.getScriptContents(this, function (context, response) {

                        context.selectedScript.label = scriptName;
                        context.selectedScript.name = scriptName.split("/").slice(-1)[0].split('.')[0];
                        context.selectedScript.code = response.data.body;

                        var scriptContents = response.data.body.replace(/\s/g, "").replace(/\n/g, "").replace(/\r/g, "");


                        console.log(scriptContents);

                        var reg = /sig[A-z0-9=,$./'" ]{1,};/g;
                        var result;
                        var detected = false;
                        while ((result = reg.exec(scriptContents)) !== null) {
                            detected = true;
                            console.log(result);
                            var params = result[0].slice(3, -1);
                            params = params.split(',');
                            console.log(params)
                            if (params) {
                                var newParams = {};
                                for (var i = 0; i < params.length; i++) {
                                    var comps = params[i].split('=');
                                    var label = comps[0].replace(/\$/g, "");
                                    var value = "";
                                    if (comps.length > 1) {
                                        value = comps[1].replace(/'/g, "").replace(/"/g, "");
                                    }
                                    newParams[label] = {"label": label, "value": value, "id": "id_param_" + label};
                                    //console.log(JSON.stringify(context.data))
                                }
                                context.data.params = newParams;

                                context.$refs.scriptParamsModal.show()
                            }

                        }

                        if (!detected) {
                            context.executeScript(scriptName, event);
                        }

                    },
                    {'name': scriptName});


            },

            viewScript: function (scriptName, event) {
                this.$store.commit('useScript', {script: scriptName});
                apitax.getScriptContents(this, function (context, response) {
                        context.selectedScript.label = scriptName;
                        context.selectedScript.name = scriptName.split("/").slice(-1)[0].split('.')[0];
                        context.selectedScript.code = response.data.body;
                        context.$refs.scriptCodeModal.show()
                    },
                    {'name': scriptName});
            },

            openScriptCreator: function (event) {
                this.creator.label = "";
                this.creator.name = "";
                this.creator.code = "";
                this.$refs.scriptCreatorModal.show();

            },

            getScriptsList: function () {

                apitax.catalogScripts(this, function (context, response) {
                    let catalog = response.data.body.scripts;

                    var arrayLength = catalog.length;
                    for (var i = 0; i < arrayLength; i++) {
                        let optionsHtml = ''
                        optionsHtml = catalog[i].path
                        catalog[i] = {...{options: optionsHtml}, ...catalog[i]};
                    }

                    context.scripts = catalog;
                    context.totalRows = catalog.length;
                });

            },

            onCmReady(cm) {
                this.codeMirror = cm;
            },

            countDownChanged(dismissCountDown) {
                this.alert.dismiss.countdown = dismissCountDown;
            },
            showAlert(message, style) {
                this.alert.text = message;
                this.alert.style = style;
                this.alert.dismiss.countdown = this.alert.dismiss.secs;
            },


            onFiltered(filteredItems) {
                // Trigger pagination to update the number of buttons/pages due to filtering
                this.totalRows = filteredItems.length
                this.currentPage = 1
            },

        },


        mounted() {
            this.getScriptsList();
        },
        created() {
            this.timer = setInterval(this.codeChange, 500)
        },
    }
</script>

