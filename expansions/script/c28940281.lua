--Gayle, Sunhewn Prodigy
local ref,id=GetID()
Duel.LoadScript("Sunhew.lua")
function ref.initial_effect(c)
	Sunhew.EnableDisengage()
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ENGAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(ref.sscon)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	c:RegisterEffect(e1)
	--Search
	local e2=Sunhew.LeaveHandTemplate(c)
	e2:Desc(1)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(ref.postg)
	e2:SetOperation(ref.posop)
	c:RegisterEffect(e2)
end

--Special Summon
function ref.sscon(e,tp,eg)
	return eg:IsExists(Card.IsControler,1,nil,tp)
		and not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function ref.ssfilter(c,e,tp)
	return Sunhew.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsCode(id)
end
function ref.ssgfilter(g)
	return g:GetClassCount(Card.GetLocation)==#g
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function ref.ssop(e,tp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),2)
	local g=Duel.GetMatchingGroup(ref.ssfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil,e,tp)
	if ft>0 and #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:SelectSubGroup(tp,ref.ssgfilter,false,1,ft)
		if #sg>0 then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
	end
end

--Set
function ref.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsCanTurnSet() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function ref.posop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsLocation(LOCATION_MZONE) then Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		else Duel.ChangePosition(tc,POS_FACEDOWN) end
	end
end
