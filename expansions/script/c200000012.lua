--Naval Gears - U-101
local cid,id=GetID()
function cid.initial_effect(c)
	--If set in back row: sp summon from deck
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_MOVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(0xff)
    e1:SetCountLimit(1,id)
    e1:SetCondition(cid.tfcon)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
		--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73452089,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(cid.discon)
	e3:SetTarget(cid.distg)
	e3:SetOperation(cid.disop)
	c:RegisterEffect(e3)
end
--negate and block targeting
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsOnField,1,nil) and Duel.IsChainNegatable(ev)
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.NegateActivation(ev) then
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		Duel.BreakEffect()
			local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE)
	e1:SetTarget(cid.notarget)
	e1:SetValue(cid.no)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	end
end
end
function cid.notarget(e,c)
	return c:IsFaceup() or not c:IsFaceup()
end
function cid.no(e,re,rp)
	return (rp==1-e:GetHandlerPlayer()) or (rp==e:GetHandlerPlayer())
end

--If set in back row: sp summon from deck
function cid.tfcon(e,tp,eg,ep,ev,re,r,rp)
return eg:IsExists(cid.condfilter,1,nil,e:GetHandler())
end
function cid.condfilter(c,card)
    return c==card and c:IsLocation(LOCATION_SZONE) and not c:IsPreviousLocation(LOCATION_SZONE)
end
function cid.filter2(c,e,tp)
	return c:IsSetCard(0x700) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsLevel(5)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chkc then return cid.filter2(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_DECK)  end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(cid.filter2,tp,LOCATION_DECK,0,1,nil) end
	
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,cid.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
	 Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) 
	   local e1=Effect.CreateEffect(e:GetHandler())
	   e1:SetCode(EFFECT_CHANGE_TYPE)
	   e1:SetType(EFFECT_TYPE_SINGLE)
	   e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	   e1:SetReset(RESET_EVENT+0x1fc0000)
	   e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
	   tc:RegisterEffect(e1)
end