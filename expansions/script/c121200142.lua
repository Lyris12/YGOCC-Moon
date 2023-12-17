--North Pole
--Idea: Alastar Rainford
--Original Scripter: Shad3

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.a_cd)
	e2:SetOperation(s.a_op)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(s.b_cs)
	e3:SetTarget(s.b_tg)
	e3:SetOperation(s.b_op)
	c:RegisterEffect(e3)
end
function s.a_fil(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(ARCHE_WINTER_SPIRIT)
end
function s.a_cd(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.a_fil,1,nil)
end
function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(COUNTER_ICE,1)
end

function s.b_fil(c,e,tp)
	return c:IsSetCard(ARCHE_WINTER_SPIRIT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.b_cs(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,COUNTER_ICE,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,COUNTER_ICE,2,REASON_COST)
end
function s.b_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.b_fil(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.b_fil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.b_fil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.b_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end