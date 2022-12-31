--Stregone dell'Illusione
--Script by XGlitchy30
function c63553465.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,c63553465.matfilter,2,2)
	c:EnableReviveLimit()
	--set/special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63553464,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,63553465)
	e1:SetCondition(c63553465.spcon)
	e1:SetCost(c63553465.spcost)
	e1:SetTarget(c63553465.sptg)
	e1:SetOperation(c63553465.spop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63553464,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,63553165)
	e2:SetCondition(c63553465.fdcon)
	e2:SetTarget(c63553465.fdtg)
	e2:SetOperation(c63553465.fdop)
	c:RegisterEffect(e2)
end
c63553465.check_same_level=0
c63553465.check_other_race=0
--filters
function c63553465.matfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
end
function c63553465.spcostfilter(c,tp,e)
	return c:IsFaceup() and c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
		and Duel.IsExistingMatchingCard(c63553465.spfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetAttribute(),e,tp)
end
function c63553465.spfilter(c,lv,attr,e,tp)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:GetLevel()==lv and not c:IsRace(attr)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c63553465.thcfilter(c,lg)
	return lg:IsContains(c)
end
function c63553465.fdfilter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or (c:GetActivateEffect():GetCondition(e,tp,eg,ep,ev,re,r,rp) and c:GetActivateEffect():GetTarget(e,tp,eg,ep,ev,re,r,rp,0)))
end
function c63553465.excfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsFaceup()
end
--set/special summon
function c63553465.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c63553465.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c63553465.spcostfilter,tp,LOCATION_MZONE,0,1,nil,tp,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c63553465.spcostfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,e):GetFirst()
	if g then
		Duel.Destroy(g,REASON_COST)
		local op=Duel.GetOperatedGroup():GetFirst()
		c63553465.check_same_level=op:GetLevel()
		c63553465.check_other_race=op:GetRace()
	end
end
function c63553465.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=c63553465.check_same_level
	local attr=c63553465.check_other_race
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c63553465.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=c63553465.check_same_level
	local attr=c63553465.check_other_race
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c63553465.spfilter,tp,LOCATION_DECK,0,1,1,nil,lv,attr,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	end
end
--search
function c63553465.fdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	return not eg:IsContains(c) and eg:FilterCount(c63553465.thcfilter,nil,lg)==2
end
function c63553465.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and Duel.IsExistingMatchingCard(c63553465.fdfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c63553465.fdop(e,tp,eg,ep,ev,re,r,rp)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft1<=0 and ft2<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(22499034,3))
	local g=Duel.SelectMatchingCard(tp,c63553465.fdfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	if tc then
		local b1=tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local b2=tc:GetActivateEffect():GetCondition(e,tp,eg,ep,ev,re,r,rp) and tc:GetActivateEffect():GetTarget(e,tp,eg,ep,ev,re,r,rp,0)
		if (b1 and ft1>0) and (not b2 or ft2<=0 or Duel.IsExistingMatchingCard(c63553465.excfilter,tp,LOCATION_SZONE,0,1,nil) or Duel.SelectYesNo(tp,aux.Stringid(63553465,2))) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			if not tc:IsLocation(LOCATION_SZONE) then
				local edcheck=0
				if tc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
				Card.SetCardData(tc,CARDDATA_TYPE,TYPE_MONSTER+TYPE_EFFECT+edcheck+aux.GetOriginalPandemoniumType(tc))
			else
				tc:RegisterFlagEffect(726,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CANNOT_DISABLE,1)
			end
		end
	end
end