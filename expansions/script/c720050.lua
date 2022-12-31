--Black Mystery Dragon Aquabizarre
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--excavate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
	function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,c)
end
	function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
	function s.filta(c,e,tp)
	return c:IsSetCard(0xb23) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
	function s.bfilter(c,tc)
	return tc:IsCode(c:GetCode()) and c:IsFaceup()
end
	function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
	and Duel.IsExistingMatchingCard(s.filta,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
	function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
		if tc:IsType(TYPE_SPELL) and tc:IsType(TYPE_FIELD+TYPE_CONTINUOUS) then
		local te=Duel.SelectMatchingCard(tp,s.filta,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if te:GetCount()>0 then
			Duel.Remove(tc,REASON_TEMPORARY)
			Duel.SpecialSummon(te,0,tp,tp,false,false,POS_FACEUP)
			Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
		end
		   Duel.SendtoDeck(tc,nil,0,REASON_EFFECT+REASON_REVEAL)
		else
			Duel.DisableShuffleCheck()
			Duel.SendtoDeck(tc,nil,0,REASON_EFFECT+REASON_REVEAL)
	end
end
	