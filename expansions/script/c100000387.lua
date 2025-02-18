--[[
The Mirror of Delirium - Spectacle ZERO
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
local FLAG_MAXX = id+100
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_POWER_VACUUM_ZONE,CARD_VACUOUS_NIGHTMARE_ZERO_HORIZON)
	--[[Target 1 "Power Vacuum Zone" you control that is not already affected by "The Mirror of Delirium - Spectacle ZERO"; it gains the following effects.
	● This card's name becomes "The Mirror of Delirium".
	● Up to thrice per turn, each time a monster(s) your opponent controls leaves the field, you gain LP equal to the highest original ATK or DEF (whichever is higher, or its ATK if tied) among those
	monsters, then if you gained 3000 or more LP this way, Special Summon 1 "Delirium Token" (Fiend/DARK/Level 12/ATK ?/DEF ?). It is unaffected by other card effects, also its original ATK/DEF
	becomes equal to that gained LP.
	● If this card leaves the field because of an opponent's card or effect: You can reveal 1 "Vacuous Nightmare - ZERO HORIZON" from your Extra Deck; Special Summon that target, ignoring its
	Summoning conditions. Its effects are negated, also its original ATK/DEF become equal to half of your current LP.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(EFFECT_COUNT_CODE_OATH|EFFECT_COUNT_CODE_DUEL)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end
--E1
function s.filter(c)
	return c:IsFaceup() and c:IsCode(CARD_POWER_VACUUM_ZONE) and not c:HasFlagEffect(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExists(true,s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and not tc:HasFlagEffect(id) then
		local c=e:GetHandler()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		local loc=tc:GetLocation()
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetRange(loc)
		e1:SetValue(CARD_THE_MIRROR_OF_DELIRIUM)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		aux.RegisterMaxxCEffect(tc,FLAG_MAXX,nil,loc,EVENT_LEAVE_FIELD,s.ctcon,s.ctopOUT,s.ctopIN,s.flaglabel,RESET_EVENT|RESETS_STANDARD)
		local e3=Effect.CreateEffect(tc)
		e3:SetDescription(id,2)
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
		e3:SetProperty(EFFECT_FLAG_DELAY)
		e3:SetCode(EVENT_LEAVE_FIELD)
		e3:SetFunctions(s.spcon,aux.DummyCost,s.sptg,s.spop)
		e3:SetReset(RESET_EVENT|RESET_TOFIELD)
		tc:RegisterEffect(e3)
		if loc==LOCATION_MZONE then
			aux.GainEffectType(tc,c)
		end
	end
end

function s.cfilter(c,p)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(p) and c:IsMonster()
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)<3 and eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.flaglabel(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil,1-tp)
	local _,val=eg:GetMaxGroup(Card.GetMaxTextStat)
	return val
end
function s.ctopOUT(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil,1-tp)
	local _,val=eg:GetMaxGroup(Card.GetMaxTextStat)
	Duel.Hint(HINT_CARD,tp,id)
	if val>0 then
		local lp=Duel.Recover(tp,val,REASON_EFFECT)
		if lp>=3000 then
			s.tkop(e,tp,lp)
		end
	end
end
function s.ctopIN(e,tp,eg,ep,ev,re,r,rp,n)
	Duel.Hint(HINT_CARD,tp,id)
	local labels={Duel.GetFlagEffectLabel(tp,FLAG_MAXX)}
	local ct=0
	for i=1,#labels do
		local val=labels[i]
		if val>0 then
			local lp=Duel.Recover(tp,val,REASON_EFFECT)
			if lp>=3000 then
				s.tkop(e,tp,lp)
			end
		end
	end
end
function s.tkop(e,tp,lp)
	if Duel.GetMZoneCount(tp)<1
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DELIRIUM,0,TYPES_TOKEN_MONSTER,lp,lp,12,RACE_FIEND,ATTRIBUTE_DARK) then
		return
	end
	local c=e:GetHandler()
	local token=Duel.CreateToken(tp,TOKEN_DELIRIUM)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(lp)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		token:RegisterEffect(e2,true)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_UNAFFECTED_BY_OTHER_EFFECT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return tc~=e:GetOwner() and tc~=e:GetHandler()
end

--E3
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_VACUOUS_NIGHTMARE_ZERO_HORIZON) and Duel.GetLocationCountFromEx(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	local tc=Duel.Select(HINTMSG_CONFIRM,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.SetTargetCard(tc)
	Duel.SetCardOperationInfo(tc,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local lp=math.floor(0.5 + Duel.GetLP(tp)/2)
		Duel.SpecialSummonMod(e,tc,0,tp,tp,true,false,POS_FACEUP,0xff,SPSUM_MOD_NEGATE,{SPSUM_MOD_CHANGE_ORIGINAL_ATKDEF,lp})
	end
end