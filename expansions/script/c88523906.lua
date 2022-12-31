--Kitseki Maschera dell'Abisso
--Script by XGlitchy30
function c88523906.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c88523906.target)
	e1:SetOperation(c88523906.activate)
	c:RegisterEffect(e1)
	--Equip limit
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetCode(EFFECT_EQUIP_LIMIT)
	e1x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1x:SetValue(1)
	c:RegisterEffect(e1x)
	--add type
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(TYPE_TUNER)
	c:RegisterEffect(e2)
end
--filters
function c88523906.eqfilter(c,eq)
	return c==eq
end
--Activate
function c88523906.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c88523906.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if not Duel.Equip(tp,e:GetHandler(),tc) then return end
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e0:SetCode(EVENT_LEAVE_FIELD_P)
		e0:SetLabelObject(c)
		e0:SetOperation(c88523906.equipprev)
		tc:RegisterEffect(e0)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCategory(CATEGORY_DECKDES)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_BE_MATERIAL)
		e1:SetLabelObject(e0)
		e1:SetCondition(c88523906.effectcon)
		e1:SetTarget(c88523906.effecttg)
		e1:SetOperation(c88523906.effectop)
		tc:RegisterEffect(e1)
	end
end
--equip check
function c88523906.equipprev(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	if g:IsExists(c88523906.eqfilter,1,nil,e:GetLabelObject()) then e:SetLabel(100) end
end
--synchro material
function c88523906.effectcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsSetCard(0x215a) 
		and e:GetLabelObject():GetLabel()==100
end
function c88523906.effecttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,4) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,4)
end
function c88523906.effectop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(1-tp,4,REASON_EFFECT)
	e:GetLabelObject():SetLabel(0)
end