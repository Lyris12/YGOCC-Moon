--created by Kinny, coded by Lyris
--Not yet finalized values
--Custom constants
EFFECT_CORONA_DRAW_COST	=550
TYPE_CORONA				=0x1000000000
TYPE_CUSTOM				=TYPE_CUSTOM|TYPE_CORONA
CTYPE_CORONA			=0x10
CTYPE_CUSTOM			=CTYPE_CUSTOM|CTYPE_CORONA
EVENT_CORONA_DRAW		=EVENT_CUSTOM+0x1600000000

--Custom Type Table
Auxiliary.Coronas={} --number as index = card, card as index = function() is_fusion

--overwrite constants
TYPE_EXTRA				=TYPE_EXTRA|TYPE_CORONA

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, card_is_able_to_extra, card_is_able_to_extra_as_cost, duel_draw = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.IsAbleToExtra, Card.IsAbleToExtraAsCost, Duel.Draw

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Coronas[c] then
		tpe=tpe|TYPE_CORONA
		if not Auxiliary.Coronas[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Coronas[c] then
		tpe=tpe|TYPE_CORONA
		if not Auxiliary.Coronas[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Coronas[c] then
		tpe=tpe|TYPE_CORONA
		if not Auxiliary.Coronas[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	return tpe
end
Card.IsAbleToExtra=function(c)
	if Auxiliary.Coronas[c] then return true end
	return card_is_able_to_extra(c)
end
Card.IsAbleToExtraAsCost=function(c)
	if Auxiliary.Coronas[c] then return true end
	return card_is_able_to_extra_as_cost(c)
end
Duel.Draw=function(tp,ct,r)
	local newct = ct
	if (Duel.GetFlagEffect(tp,1600000000)==0) and Duel.IsExistingMatchingCard(Auxiliary.CoronaFilterNeo,tp,LOCATION_EXTRA,0,1,nil,ct) and Duel.SelectYesNo(tp,572) then
		local tc = Auxiliary.CoronaOp(tp,ct,REASON_RULE)
		newct = ct - 1 --tc:GetAura()
		Duel.RaiseEvent(tc,EVENT_CORONA_DRAW,nil,r,tp,tp,99)
	end
	return duel_draw(tp,newct,r) + (ct-newct)
end

--Custom Functions
function Auxiliary.EnableCoronaNeo(c,aura,mat_count,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	table.insert(Auxiliary.Coronas,c)
	Auxiliary.Coronas[c]=function() return true end
	Auxiliary.Customs[c]=true
	--Functions
	local funcs={...}
	--Add Aura
	local mt=getmetatable(c)
	mt.aura = aura
	mt.original_type = (c:GetType()-TYPE_FUSION)
	mt.corona_materials = funcs
	mt.material_count = mat_count
	
	--Draw replace
	--[[local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EVENT_CHAIN_SOLVING)
	e0:SetOperation(Auxiliary.CoronaDrawOp)
	c:RegisterEffect(e0)]]
	--Destruction replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetTarget(Auxiliary.CoronaDesRepTg)
	e3:SetValue(Auxiliary.CoronaDesRepVal)
	c:RegisterEffect(e3)
	
	if not Global_CoronaRedirects then
		Global_CoronaRedirects=true
		--Redirect
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_DECK_REDIRECT)
		ge1:SetTargetRange(0xff,0xff)
		ge1:SetTarget(Auxiliary.CoronaToExtra)
		ge1:SetValue(LOCATION_EXTRA)
		Duel.RegisterEffect(ge1,0)
	end
end
g_CoronaTracker={0,0}
g_CoronaTracker[0]=0
g_CoronaTracker[1]=0
g_CoronaCount={0,0}
g_CoronaCount[0]=0
g_CoronaCount[1]=0
function Auxiliary.CoronaOp(tp,val,r)
	local tc=Duel.SelectMatchingCard(tp,Auxiliary.CoronaFilterNeo,tp,LOCATION_EXTRA,0,1,1,nil,val):GetFirst()
	local aura=tc:GetAura()
	
	local cg=Group.CreateGroup()
	for key,value in pairs(tc.corona_materials) do
		if not cg:IsExists(tc.corona_materials[key],1,nil) then
			local sg=Duel.GetMatchingGroup(tc.corona_materials[key],tp,LOCATION_GRAVE,0,nil)
			sg:Sub(cg)
			local cc=sg:Select(tp,1,1,nil):GetFirst()
			cg:AddCard(cc)
		end
	end
	local ct=tc.material_count - #cg
	if ct>0 then
		local sg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_GRAVE,0,ct,ct,nil)
		cg:Merge(sg)
	end
	Duel.Remove(cg,POS_FACEUP,REASON_COST+REASON_MATERIAL+1600000000)
	
	aux.AddCoronaToHand(tc,r,tc.original_type)
	--Duel.Recover(tp,aura*500,REASON_RULE)
	if (r==REASON_RULE) then Duel.RegisterFlagEffect(tp,1600000000,RESET_PHASE+PHASE_END,1,0) end
	return tc
end
function Auxiliary.CoronaDrawOp(e,tp,eg,ep,ev,re,r,rp)
	local p,d,id=Duel.GetChainInfo(ev,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM,CHAININFO_CHAIN_ID)
	local ex = (Duel.GetOperationInfo(ev,CATEGORY_DRAW) or re:IsHasCategory(CATEGORY_DRAW))
	local user = (ep==tp) and (p==tp) and (rp==tp)
	if not (user and ex and (g_CoronaTracker[tp]~=id) and (Duel.GetFlagEffect(tp,1600000000)==0)
		and Duel.IsExistingMatchingCard(Auxiliary.CoronaFilterNeo,tp,LOCATION_EXTRA,0,1,nil,d)) then return end
	g_CoronaTracker[tp]=id
	if d>0 and Duel.SelectYesNo(tp,572) then
		--[[local invest=0
		if d==1 then invest = 1 else
			invest = Duel.AnnounceLevel(tp,1,d,nil)
		end]]
		local tc = Auxiliary.CoronaOp(tp,d,REASON_RULE)
		Duel.ChangeTargetParam(ev,d-tc:GetAura())
	end
end
function Auxiliary.CoronaDesRepFilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function Auxiliary.CoronaDesRepTg(e,tp,eg,ep,ev,re,r,rp,chk)
	if rp~=tp then return false end
	local id=0
	if re then id=re:GetHandler():GetCode() end
	local ct=eg:FilterCount(Auxiliary.CoronaDesRepFilter,nil,tp)
	if chk==0 then return (rp==tp and ct>0 and (g_CoronaTracker[tp]~=id) and (Duel.GetFlagEffect(tp,1600000000)==0)
		and Duel.IsExistingMatchingCard(Auxiliary.CoronaFilterNeo,tp,LOCATION_EXTRA,0,1,nil,ct)) end
	g_CoronaTracker[tp]=id
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),573) then
		Auxiliary.CoronaOp(tp,ct,REASON_RULE)
		return true
	else return false end
end

function Auxiliary.CoronaDesRepVal(e,c)
	return Auxiliary.CoronaDesRepFilter(c,e:GetHandlerPlayer())
end

function Auxiliary.CoronaFilterNeo(c,ct)
	if not (c:IsType(TYPE_CORONA) and c:GetAura()<=ct and (Duel.GetFieldGroupCount(c:GetControler(),LOCATION_GRAVE,0)>=c.material_count)) then return false end
	for key,value in pairs(c.corona_materials) do
		if not Duel.IsExistingMatchingCard(c.corona_materials[key],c:GetControler(),LOCATION_GRAVE,0,1,nil,nil) then return false end
	end
	return true
end
--Shorthand for "If you performed a Corona Draw this turn"
function Auxiliary.cdrewcon(e,tp)
	return Duel.GetFlagEffect(tp,1600000000)~=0
end
--Add Corona to hand
function Auxiliary.AddCoronaToHand(tc,reason,tpe)
	local tp=tc:GetOwner()
	Duel.MoveSequence(tc,0)
	Duel.MoveToField(tc,tp,tp,LOCATION_HAND,POS_FACEDOWN_ATTACK,true)
	tc:SetCardData(CARDDATA_TYPE,tpe)
	Duel.SendtoHand(tc,tp,reason)
	Duel.ConfirmCards(1-tp,tc)
	Duel.RaiseEvent(tc,EVENT_DRAW,e,REASON_RULE,tp,tp,1)
	Duel.RaiseEvent(tc,EVENT_CORONA_DRAW,e,REASON_RULE,tp,tp,1)
end
--Corona Redirect (ED card)
function Auxiliary.CoronaToExtra(e,c)
	if c:IsType(TYPE_CORONA) then
		Duel.MoveSequence(c,0)
		Card.SetCardData(c,CARDDATA_TYPE,c.original_type+TYPE_FUSION)
		return true
	end
	return false
end
--Aura Functions
function Card.GetAura(c)
	if not c.aura then return 0 end
	return c.aura
end
function Card.IsAuraBelow(c,val)
	if not c.aura then return false end
	return c.aura <= val
end
function Card.IsAuraAbove(c,val)
	if not c.aura then return false end
	return c.aura >= val
end
