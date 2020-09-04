--Card-Mistress Dark Valkyria
function c249000589.initial_effect(c)
	c:EnableCounterPermit(0x1)
	--summon success
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22923081,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c249000589.addtg)
	e1:SetOperation(c249000589.addop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--xyz while face-up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(0xFF)	
	e4:SetOperation(c249000589.xyzop)
	c:RegisterEffect(e4)
	--remove overlay replace
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(32999573,0))
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c249000589.rcon)
	e5:SetOperation(c249000589.rop)
	c:RegisterEffect(e5)
	--copy
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(30312361,0))
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,249000589)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCost(c249000589.cost)
	e6:SetTarget(c249000589.target)
	e6:SetOperation(c249000589.operation)
	c:RegisterEffect(e6)
end
function c249000589.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
function c249000589.addop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,2)
	end
end
function c249000589.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_PENDULUM
end
function c249000589.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then return end
	if not c:IsType(TYPE_XYZ) and (not c:IsLocation(LOCATION_MZONE) or not c:IsFaceup()) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then Card.SetCardData(c,CARDDATA_TYPE,c:GetType()+TYPE_XYZ) end
	if not (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) and c:IsType(TYPE_XYZ) then Card.SetCardData(c,CARDDATA_TYPE,c:GetType()+TYPE_XYZ) end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	c:RegisterEffect(e2)
end
function c249000589.rcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_COST)~=0 and re:IsHasType(0x7e0) and re:GetHandler()==e:GetHandler()
		and e:GetHandler():IsCanRemoveCounter(tp,0x1,ev,REASON_COST)
end
function c249000589.rop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x1,ev,REASON_COST)
end
function c249000589.costfilter(c)
	return c:IsSetCard(0x1D4) and c:IsAbleToRemoveAsCost()
end
function c249000589.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000589.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249000589.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249000589.tfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsAbleToRemove()
end
function c249000589.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000589.tfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
end
function c249000589.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local g=Duel.SelectMatchingCard(tp,c249000589.tfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,c249000589.tfilter)
		if g then
			local e1=Effect.CreateEffect(e:GetHandler())
			local lvrk
			if g:GetFirst():GetRank()>0 then lvrk=g:GetFirst():GetRank() else lvrk=g:GetFirst():GetLevel() end
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			e1:SetValue(lvrk*200)
			c:RegisterEffect(e1)
			--add code
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,1)
			e2:SetCode(EFFECT_ADD_CODE)
			e2:SetValue(g:GetFirst():GetOriginalCode())
			e2:SetLabelObject(e1)
			c:RegisterEffect(e2)
			local cid=c:CopyEffect(g:GetFirst():GetOriginalCode(),RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,1)
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(30312361,1))
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_PHASE+PHASE_END)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e3:SetCountLimit(1)
			e3:SetRange(LOCATION_MZONE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetLabel(cid)
			e3:SetLabelObject(e2)
			e3:SetOperation(c249000589.rstop)
			c:RegisterEffect(e3)
		end
	end
end
function c249000589.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	local e2=e:GetLabelObject()
	local e1=e2:GetLabelObject()
	e1:Reset()
	e2:Reset()
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end