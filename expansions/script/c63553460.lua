--Rinascita Strax
--Script by XGlitchy30
function c63553460.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63553460,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,63553460+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c63553460.target)
	e1:SetOperation(c63553460.activate)
	c:RegisterEffect(e1)
	--switch position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63553457,2))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c63553460.postg)
	e2:SetOperation(c63553460.posop)
	c:RegisterEffect(e2)
end
--filters
function c63553460.filter(c,e,tp)
	return c:IsSetCard(0x4554) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c63553460.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x4554) and c:GetLevel()>0 and c:IsDiscardable()
end
function c63553460.ctfilter(c)
	return c:GetCounter(0x1554)>0
end
function c63553460.posfilter(c)
	return c:IsCanChangePosition()
end
--Activate
function c63553460.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c63553460.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c63553460.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c63553460.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c63553460.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
		if not Duel.IsExistingMatchingCard(c63553460.costfilter,tp,LOCATION_HAND,0,1,nil) then return end
		if Duel.SelectYesNo(tp,aux.Stringid(63553460,1)) then
			if Duel.DiscardHand(tp,c63553459.costfilter,1,1,REASON_COST+REASON_DISCARD) then
				local op=Duel.GetOperatedGroup():GetFirst()
				e:SetLabel(op:GetLevel())
				if not Duel.IsCanAddCounter(tp,0x1554,e:GetLabel(),tc) then return end
				tc:AddCounter(0x1554,e:GetLabel())
			end
		end
	end
end
--switch position
function c63553460.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c63553460.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ft=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local sum=0
	for tc in aux.Next(g) do
		local ctct=tc:GetCounter(0x1554)
		sum=sum+ctct
	end
	if sum>ft then
		sum=ft
	end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and sum>0 and Duel.IsExistingMatchingCard(c63553460.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,sum,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c63553460.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c63553460.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ft=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local sum=0
	for tc in aux.Next(g) do
		local ctct=tc:GetCounter(0x1554)
		sum=sum+ctct
	end
	if sum<=0 then return end
	if sum>ft then
		sum=ft
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c63553460.posfilter,tp,0,LOCATION_MZONE,sum,sum,nil)
	if g:GetCount()>0 then
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end