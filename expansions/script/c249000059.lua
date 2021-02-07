--Change Sentai - Blue
function c249000059.initial_effect(c)
	return
	c:SetUniqueOnField(1,0,249000059)
	--copy effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetCost(c249000059.cost)
	e1:SetTarget(c249000059.target)
	e1:SetOperation(c249000059.operation)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c249000059.spcon)
	c:RegisterEffect(e2)
end
function c249000059.costfilter(c)
	return c:IsSetCard(0xA5) and c:IsAbleToRemoveAsCost()
end
function c249000059.costfilter2(c,e)
	return c:IsSetCard(0xA5) and not c:IsPublic()
end
function c249000059.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000059.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000059.costfilter2,tp,LOCATION_HAND,0,1,nil)) end
	local option
	if Duel.IsExistingMatchingCard(c249000059.costfilter2,tp,LOCATION_HAND,0,1,nil)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000059.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000059.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000059.costfilter2,tp,LOCATION_HAND,0,1,nil) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000059.costfilter2,tp,LOCATION_HAND,0,1,1,nil,e)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000059.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000059.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:IsAbleToGrave() and c:IsLevelAbove(1)
end
function c249000059.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000059.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function c249000059.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c249000059.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
			local atk=g:GetFirst():GetLevel()*100
			local code=g:GetFirst():GetOriginalCode()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END-RESET_TOGRAVE-RESET_TOFIELD)
			e1:SetCode(EFFECT_ADD_CODE)
			e1:SetValue(code)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END-RESET_TOGRAVE-RESET_TOFIELD)
			e2:SetValue(atk)
			e2:SetLabelObject(e1)
			c:RegisterEffect(e2)		
			local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END-RESET_TOGRAVE-RESET_TOFIELD,1)
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(30312361,1))
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_PHASE+PHASE_END)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e3:SetCountLimit(1)
			e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END-RESET_TOGRAVE-RESET_TOFIELD)
			e3:SetLabel(cid)
			e3:SetLabelObject(e2)
			e3:SetOperation(c249000059.rstop)
			c:RegisterEffect(e3)
		end
	end
end
function c249000059.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10A5) and c:GetCode()~=249000059
end
function c249000059.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(c249000059.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end