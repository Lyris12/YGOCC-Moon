--Number P196: Psy Cat
function c249001079.initial_effect(c)
	aux.AddCodeList(c,249001075)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c249001079.splimit)
	c:RegisterEffect(e0)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1113)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetCondition(c249001079.discon)
	e1:SetCost(c249001079.discost)
	e1:SetTarget(c249001079.distg)
	e1:SetOperation(c249001079.disop)
	c:RegisterEffect(e1)
end
c249001079.xyz_number=196
function c249001079.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c249001079.cfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:GetControler()==tp
end
function c249001079.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or re:GetOwnerPlayer()==tp then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(c249001079.cfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function c249001079.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c249001079.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,249001075) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function c249001079.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRelateToEffect(re) and re:GetHandler():GetControler()==1-tp and re:GetHandler():IsLocation(LOCATION_MZONE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(re:GetHandler():GetAttack()/2))
		re:GetHandler():RegisterEffect(e1)
	end
end
