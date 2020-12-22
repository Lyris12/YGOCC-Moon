--Conquest Dancer of The Godspark - Azura
--Created and Scripted by Swaggy
local m=4200115
local cm=_G["c"..m]
cm.dfc_back_side=m-1
cm.card_code_list={33700056}
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
function cm.initial_effect(c)
	Senya.DFCBackSideCommonEffect(c)
		c:SetUniqueOnField(1,0,4200115)
--Double Attribute
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_DARK)
c:RegisterEffect(e1)
--Proteccion
local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	e2:SetCondition(cm.ntcon)
c:RegisterEffect(e2)
local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(aux.indoval)
	e3:SetCondition(cm.indescon)
c:RegisterEffect(e3)
--Two Quickies for the price of none
local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(2,m)
	e4:SetCost(cm.tucost)
	e4:SetTarget(cm.tutarget)
	e4:SetCondition(cm.tucon)
	e4:SetOperation(cm.tuop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(2,m)
	e5:SetCost(cm.bancost)
	e5:SetTarget(cm.bantarget)
	e5:SetCondition(cm.bancon)
	e5:SetOperation(cm.banop)
	c:RegisterEffect(e5)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(2,m)
	e5:SetCost(cm.negcost)
	e5:SetTarget(cm.negtarget)
	e5:SetCondition(cm.negcon)
	e5:SetOperation(cm.negop)
	c:RegisterEffect(e5)
end
function cm.ntfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x412) and c:IsType(TYPE_XYZ)
end
function cm.ntcon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(cm.ntfilter,1,nil)
end
function cm.indescon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(cm.ntfilter,1,nil)
end
function cm.sparkfilter(c)
return c:IsCode(4200100)
end
function cm.tucon(e,c)
	return Duel.IsExistingMatchingCard(cm.sparkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function cm.tucost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFlagEffect(tp,4200115)<=0 end
	Duel.RegisterFlagEffect(tp,4200115,RESET_PHASE+PHASE_END,0,1)
end
function cm.tutarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.tuop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function cm.bancon(e,c)
	return Duel.IsExistingMatchingCard(cm.sparkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function cm.bancost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFlagEffect(tp,5200115)<=0 end
	Duel.RegisterFlagEffect(tp,5200115,RESET_PHASE+PHASE_END,0,1)
end
function cm.bantarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()~=tp and chkc:GetLocation()==LOCATION_GRAVE and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
function cm.banop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function cm.negcon(e,c)
	return Duel.IsExistingMatchingCard(cm.sparkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function cm.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFlagEffect(tp,6200115)<=0 end
	Duel.RegisterFlagEffect(tp,6200115,RESET_PHASE+PHASE_END,0,1)
end
function cm.negtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.disfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.disfilter1,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.disfilter1,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function cm.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end