--[[
Curseflame Hexer Oriem
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()

local FLAG_MAXX	= id+100

function s.initial_effect(c)
	aux.EnableLinkRatingMods=true
	aux.EnablePendulumAttribute(c,false)
	--You cannot Pendulum Summon monsters, except "Curseflame" monsters. This effect is negated while there are 6 or more Curseflame Counters on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.pspcon)
	e1:SetTarget(s.psplimit)
	c:RegisterEffect(e1)
	--When this card is activated: You can target 1 "Curseflame" Continuous Spell/Trap in your GY; replace this effect with that card's effects.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e2)
	--[[Each time a card(s) with a Curseflame Counter(s) on it leaves the field, place Curseflame Counters on this card, equal to the total number of Curseflame Counters that were on those cards on
	the field.]]
	aux.RegisterMaxxCEffect(c,FLAG_MAXX,nil,LOCATION_PZONE,EVENT_LEAVE_FIELD_P,s.ctcon,s.ctopOUT,s.ctopIN,s.flaglabel)
	--[[During your Main Phase, if this card is in your hand, GY, or face-up Extra Deck: You can shuffle 2 of your other "Curseflame" cards that are in your hand, GY, and/or banishment into the Deck;
	Special Summon this card, and if you do, place 1 Curseflame Counter on each face-up card your opponent controls.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		aux.ToDeckCost(aux.FaceupExFilter(Card.IsSetCard,ARCHE_CURSEFLAME),LOCATION_HAND|LOCATION_GB,0,2,2,true),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e3)
	--[[All face-up monsters your opponent controls with a Curseflame Counter(s) on them have their Level/Rank/Link Rating/Future reduced by 1 for each Curseflame Counter on the field (min. 1).]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_LEVEL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(aux.TargetBoolFunction(Card.HasCounter,COUNTER_CURSEFLAME))
	e4:SetValue(s.lvval)
	c:RegisterEffect(e4)
	local e4a=e4:Clone()
	e4a:SetCode(EFFECT_UPDATE_RANK)
	c:RegisterEffect(e4a)
	local e4b=e4:Clone()
	e4b:SetCode(EFFECT_UPDATE_LINK_RATING_GLITCHY)
	c:RegisterEffect(e4b)
	local e4c=e4:Clone()
	e4c:SetCode(EFFECT_UPDATE_FUTURE)
	c:RegisterEffect(e4c)
end
--E1
function s.pspcon(e)
	return Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)<6
end
function s.psplimit(e,c,tp,sumtp,sumpos)
	return (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and c:IsSetCard(ARCHE_CURSEFLAME)
end

--E2
function s.cpfilter(c)
	return c:IsST(TYPE_CONTINUOUS) and c:IsSetCard(ARCHE_CURSEFLAME)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.cpfilter(chkc) end
	if chk==0 then return true end
	if not Duel.PlayerHasFlagEffect(tp,id) and Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,STRING_ASK_TARGET) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and c:IsFaceup() and c:IsRelateToChain() then
		local code=tc:GetOriginalCode()
		c:CopyEffect(code,RESET_EVENT|RESETS_STANDARD)
		if code==920017 or code==920019 then
			local op=tc:GetActivateEffect():GetOperation()
			op(e,tp,eg,ep,ev,re,r,rp)
		end
		c:SetHint(CHINT_CARD,code)
	end
end

--Last Pendulum Effect
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.HasCounter,1,nil,COUNTER_CURSEFLAME)
end
function s.flaglabel(e,tp,eg,ep,ev,re,r,rp)
	local val=eg:GetSum(Card.GetCounter,COUNTER_CURSEFLAME)
	if not val then val=0 end
	return val
end
function s.ctopOUT(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=eg:GetSum(Card.GetCounter,COUNTER_CURSEFLAME)
	if c:IsCanAddCounter(COUNTER_CURSEFLAME,ct) then
		Duel.Hint(HINT_CARD,tp,id)
		c:AddCounter(COUNTER_CURSEFLAME,ct)
	end
end
function s.ctopIN(e,tp,eg,ep,ev,re,r,rp,n)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,tp,id)
	local labels={Duel.GetFlagEffectLabel(tp,FLAG_MAXX)}
	local ct=0
	for i=1,#labels do
		ct=ct+labels[i]
	end
	if c:IsCanAddCounter(COUNTER_CURSEFLAME,ct) then
		Duel.Hint(HINT_CARD,tp,id)
		c:AddCounter(COUNTER_CURSEFLAME,ct)
	end
end

--E3
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(Card.IsCanAddCounter,tp,0,LOCATION_ONFIELD,nil,COUNTER_CURSEFLAME,1)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and #g>0
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,#g,0,COUNTER_CURSEFLAME)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Group(Card.IsCanAddCounter,tp,0,LOCATION_ONFIELD,nil,COUNTER_CURSEFLAME,1)
		for tc in aux.Next(g) do
			tc:AddCounter(COUNTER_CURSEFLAME,1)
		end
	end
end

--E4
function s.lvval(e,c)
	return -Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
end