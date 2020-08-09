--Phantomb Guardian, Heaven Blade
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,ref=getID()
function ref.initial_effect(c)
	--Types
	c:EnableReviveLimit()
	aux.AddOrigPandemoniumType(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCode(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(aux.PandActCheck)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	aux.EnablePandemoniumAttribute(c,e1,TYPE_RITUAL+TYPE_EFFECT+TYPE_PANDEMONIUM,nil,nil,1,nil,false)
	--Gain Effects
	---Recur
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(ref.matctcon(1))
	e2:SetCountLimit(1,id)
	e2:SetTarget(ref.dsstg)
	e2:SetOperation(ref.dssop)
	c:RegisterEffect(e2)
	---Reborn
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCountLimit(1,id+1000)
	e3:SetCondition(ref.matctcon(2))
	e3:SetTarget(ref.sstg)
	e3:SetOperation(ref.ssop)
	c:RegisterEffect(e3)
	---Float
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetCondition(ref.repcon)
	e4:SetTarget(ref.reptg)
	c:RegisterEffect(e4)
end

--Activate
function ref.actfilter(c,e,tp)
	return c:IsSetCard(0x732) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not c:IsLocation(LOCATION_EXTRA) or Duel.GetLocationCountFromEx(tp)>0)
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(ref.actfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function ref.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return false end
	local ct=1
	if Duel.IsExistingMatchingCard(ref.exfilter,tp,0,LOCATION_ONFIELD,1,nil) then ct=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.actfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,ct,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Destroy(c,REASON_EFFECT)
	end
end

--Shared Conditions
function ref.matctcon(ct)
	return function(e)
		local c=e:GetHandler()
		local mg=c:GetMaterial()
		return c:GetSummonType()==SUMMON_TYPE_RITUAL and #mg>=ct
	end
end
--Recurr
function ref.thfilter(c)
	return c:IsSetCard(0x732) and c:IsFaceup() and c:IsAbleToHand()
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(ref.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function ref.dssfilter(c,e,tp)
	return c:IsSetCard(0x732) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.dsstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(ref.dssfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function ref.dssop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.dssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
--Reborn
function ref.ssfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(ref.ssfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
--Float
function ref.repcon(e)
	return bit.band(e:GetHandler():GetSummonLocation(),LOCATION_DECK)~=LOCATION_DECK
		--bit.band(e:GetHandler():GetSummonLocation(),LOCATION_HAND)==LOCATION_HAND
		--or bit.band(e:GetHandler():GetSummonLocation(),LOCATION_EXTRA)==LOCATION_EXTRA
end
function ref.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	if Duel.SelectEffectYesNo(tp,c,96) then
		aux.PandSSet(c,REASON_EFFECT,aux.GetOriginalPandemoniumType(c))(e,tp,eg,ep,ev,re,r,rp)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		return true
	else return false end
end