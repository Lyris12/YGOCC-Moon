--Snawfus Support Spirit
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),6,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	--You take no battle damage from attacks involving Beast monsters you control.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Once per turn: You can discard 1 card, then target 1 Level 3 or lower Beast monster in your GY; Special Summon it.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(aux.DiscardCost())
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsXyzType(TYPE_XYZ) and c:IsRankBelow(3)
end
function s.xyzop(e,tp,chk,mc)
	local ct=mc:GetOverlayCount()
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and ct>0 and mc:CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	mc:RemoveOverlayCard(tp,ct,ct,REASON_COST)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end

function s.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end