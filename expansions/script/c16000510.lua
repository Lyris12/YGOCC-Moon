--Scooby, Flare Boi of Rose VINE
function c16000510.initial_effect(c)
	  --link summon
	aux.AddLinkProcedure(c,c16000510.mfilter,2)
	c:EnableReviveLimit()
	  --Make Sum E-C pls uwu
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16000510,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c16000510.destg)
	e1:SetOperation(c16000510.desop)
	c:RegisterEffect(e1)
   --spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16000510,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c16000510.sptg)
	e2:SetOperation(c16000510.spop)
	c:RegisterEffect(e2) 
end

function c16000510.mfilter(c)
	return c:IsSetCard(0x85a) and c:IsType(TYPE_MONSTER) and not c:IsLinkType(TYPE_LINK)
end
function c16000510.filter(c,e,tp)
	return c:IsSetCard(0x85a) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c16000510.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c16000510.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function c16000510.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16000510.filter),tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
   function c16000510.thfilter(c,g)
	return c:IsFaceup() and c:IsSetCard(0x685a) and c:IsType(CTYPE_EVOLUTE) and g:IsContains(c)
end
function c16000510.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	  if chkc then return chkc:IsCanAddCounter(0x88,3) and c16000510.thfilter(chkc,lg) end
	if chk==0 then return Duel.IsExistingTarget(c16000510.thfilter,tp,LOCATION_MZONE,0,1,nil,lg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c16000510.thfilter,tp,LOCATION_MZONE,0,1,1,nil,lg)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0)
end
function c16000510.desop(e,tp,eg,ep,ev,re,r,rp)
	 local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x88,3) then
		tc:AddCounter(0x88,3)
	end
end