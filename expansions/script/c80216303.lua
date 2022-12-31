--Cursed Ennigmatrix
--Script by XGlitchy30
--edited by Eaden
local cid,id=GetID()
function cid.initial_effect(c)
	--unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.immcon)
	e1:SetTarget(cid.immtg)
	e1:SetOperation(cid.immop)
	c:RegisterEffect(e1)
	--get effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(cid.attachcon)
	e2:SetTarget(cid.attachtg)
	e2:SetOperation(cid.attachop)
	c:RegisterEffect(e2)
end
--filters
function cid.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x2ead) and c:IsType(TYPE_XYZ)
end
function cid.efilter(e,te)
	local c=e:GetHandler()
	local ec=te:GetHandler()
	if ec:IsHasCardTarget(c) then return true end
	return te:IsHasType(EFFECT_TYPE_ACTIONS) and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and c:IsRelateToEffect(te)
end
function cid.xyzfilter(c)
	return c:IsSetCard(0xead) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
--unaffected
function cid.immcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(cid.tfilter,1,nil,tp)
end
function cid.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		return g:IsExists(cid.tfilter,1,nil,tp) 
	end
end
function cid.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(cid.tfilter,nil,tp)
	if #g<=0 then return end
	local tg,tc
	if #g>1 then
		tg=g:Select(tp,1,1,nil)
		tc=tg:GetFirst()
	else
		tc=g:GetFirst()
	end
	if c:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		if tg then
			Duel.HintSelection(tg)
		end
		Duel.Overlay(tc,Group.FromCards(c))
		if tc:GetOverlayGroup():IsContains(c) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(cid.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
--get effect
function cid.attachcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0xead) and c:IsType(TYPE_XYZ) and c:IsType(TYPE_MONSTER)
		and Duel.GetTurnPlayer()==tp
end
function cid.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and cid.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.xyzfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(cid.xyzfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gg,#gg,0,0)
	end
end
function cid.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Duel.Overlay(c,Group.FromCards(tc))
		Duel.BreakEffect()
		local ov=c:GetOverlayGroup()
		if #ov<=0 then return end
		Duel.Recover(tp,ov:GetCount()*100,REASON_EFFECT)
	end
end