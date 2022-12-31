--Ritmi Mistici - Campanaro Giustiziere
--Script by XGlitchy30
function c76565326.initial_effect(c)
	c:EnableCounterPermit(0x1555)
	--COUNTER TRACKER
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetRange(LOCATION_SZONE)
	e0:SetOperation(c76565326.ctop0)
	c:RegisterEffect(e0)
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0x:SetRange(LOCATION_SZONE)
	e0x:SetCode(EVENT_CHAIN_SOLVED)
	e0x:SetLabelObject(e0)
	e0x:SetOperation(c76565326.ctop1)
	c:RegisterEffect(e0x)
	--RESET COUNTER_TRACKER
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e00:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e00:SetCode(EVENT_LEAVE_FIELD)
	e00:SetLabelObject(e0)
	e00:SetOperation(c76565326.reset1)
	c:RegisterEffect(e00)
	local e000=Effect.CreateEffect(c)
	e000:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e000:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e000:SetCode(EVENT_SSET)
	e000:SetLabelObject(e0)
	e000:SetOperation(c76565326.reset0)
	c:RegisterEffect(e000)
	--add counters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,76565326+EFFECT_COUNT_CODE_OATH)
	e1:SetLabelObject(e0x)
	e1:SetTarget(c76565326.target)
	e1:SetOperation(c76565326.activate)
	c:RegisterEffect(e1)
	--negate on destruction
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,76165326)
	e2:SetLabelObject(e0x)
	e2:SetTarget(c76565326.negtg)
	e2:SetOperation(c76565326.negop)
	c:RegisterEffect(e2)
	--negate on removal
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CUSTOM+76565326)
	e3:SetLabelObject(e0x)
	e3:SetCountLimit(1,76265326)
	e3:SetTarget(c76565326.sctg)
	e3:SetOperation(c76565326.scop)
	c:RegisterEffect(e3)
end
--filters
function c76565326.spfilter(c,e,tp)
	return c:IsSetCard(0x7555) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c76565326.negfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end
--counter tracker
function c76565326.ctop0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=c:GetCounter(0x1555)
	e:SetLabel(count)
end
function c76565326.ctop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local prev=e:GetLabelObject():GetLabel()
	if not prev then prev=0 end
	if c:GetCounter(0x1555)<prev then
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+76565326,e,0,0,tp,0)
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+76565329,e,REASON_EFFECT,tp,tp,prev-c:GetCounter(0x1555))
		e:SetLabel(c:GetCounter(0x1555))
		e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()-prev+c:GetCounter(0x1555))
	else
		e:SetLabel(c:GetCounter(0x1555))
		e:GetLabelObject():SetLabel(e:GetLabel())
	end
end
--reset counter tracker
function c76565326.reset1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
function c76565326.reset0(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
--add counters
function c76565326.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1555,3,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1555)
end
function c76565326.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1555,3)
		e:GetLabelObject():GetLabelObject():SetLabel(0)
		e:GetLabelObject():SetLabel(0)
	end
end
--destroy and negate
function c76565326.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT) end
end
function c76565326.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT) then
		c:RemoveCounter(tp,0x1555,1,REASON_EFFECT)
		Duel.BreakEffect()
		if c:GetCounter(0x1555)==0 then
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+76565329,e,REASON_EFFECT,tp,tp,1)
			if Duel.Destroy(c,REASON_EFFECT)~=0 then
				e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()+1)
				if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
					if g:GetCount()>0 then
						Duel.HintSelection(g)
						local tc=g:GetFirst()
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetCode(EFFECT_DISABLE)
						e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
						tc:RegisterEffect(e1)
						local e2=Effect.CreateEffect(e:GetHandler())
						e2:SetType(EFFECT_TYPE_SINGLE)
						e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e2:SetCode(EFFECT_DISABLE_EFFECT)
						e2:SetValue(RESET_TURN_SET)
						e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
						tc:RegisterEffect(e2)
					end
				end
			end
		end
	end
end
--negate when counter is removed
function c76565326.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c76565326.negfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c76565326.negfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c76565326.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function c76565326.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end