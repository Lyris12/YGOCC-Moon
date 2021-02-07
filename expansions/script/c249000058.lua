--Change Sentai - Red
function c249000058.initial_effect(c)
	return
	c:SetUniqueOnField(1,0,249000058)
	--copy effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetCost(c249000058.cost)
	e1:SetTarget(c249000058.target)
	e1:SetOperation(c249000058.operation)
	c:RegisterEffect(e1)
	--summon & set with no tribute
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75498415,0))
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c249000058.ntcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e3)
end
function c249000058.costfilter(c)
	return c:IsSetCard(0xA5) and c:IsAbleToRemoveAsCost()
end
function c249000058.costfilter2(c,e)
	return c:IsSetCard(0xA5) and not c:IsPublic()
end
function c249000058.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000058.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000058.costfilter2,tp,LOCATION_HAND,0,1,nil)) end
	local option
	if Duel.IsExistingMatchingCard(c249000058.costfilter2,tp,LOCATION_HAND,0,1,nil)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000058.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000058.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000058.costfilter2,tp,LOCATION_HAND,0,1,nil) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000058.costfilter2,tp,LOCATION_HAND,0,1,1,nil,e)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000058.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000058.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:IsAbleToGrave() and c:IsLevelAbove(1)
end
function c249000058.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000058.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function c249000058.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c249000058.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
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
			e3:SetOperation(c249000058.rstop)
			c:RegisterEffect(e3)
		end
	end
end
function c249000058.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
end