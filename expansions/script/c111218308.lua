local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
--created by NeverThisAgain, coded by Lyris
--Clearical Diamond Prison
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsSetCard,0x50b),aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.activate)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	e3:SetCondition(function(e) local tc=e:GetHandler() return tc:IsSummonType(SUMMON_TYPE_SPECIAL) and tc:GetSummonLocation()==LOCATION_GRAVE end)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCondition(function(e,tp) local tc=e:GetHandler() return tc:IsSummonType(SUMMON_TYPE_SPECIAL) and tc:GetSummonLocation()==LOCATION_GRAVE and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil) end)
	e1:SetTarget(cid.rmtg)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and bit.band(c:GetType(),0x81)==0x81 and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP)
	end
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
function cid.rmfilter(c,tp,e)
	local g=c:GetMaterial()
	return c:GetSummonLocation()==LOCATION_EXTRA and c:GetSummonPlayer()~=tp
		and (not e or c:IsRelateToEffect(e)) and c:IsAbleToRemove()
end
function cid.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(cid.rmfilter,nil,tp)
	if chk==0 then return #g==1 end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function cid.matfilter(c,tp,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp)
		and c:IsAbleToRemove() and c:GetReasonCard()==rc
		and c:IsReason(REASON_MATERIAL)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(cid.rmfilter,nil,tp,e)
	local tc=g:GetFirst()
	local mg=tc:GetMaterial()
	if tc and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and (not mg or #mg==0 or mg:IsExists(cid.matfilter,#g,nil,tp,tc)) then
		Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
	end
end
