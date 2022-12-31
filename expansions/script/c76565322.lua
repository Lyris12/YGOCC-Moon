--Ritmi Mistici - Quartetto Dirompente
--Script by XGlitchy30
function c76565322.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1555)
	--counter check
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK+LOCATION_REMOVED)
	e0:SetCode(EVENT_CUSTOM+76565329)
	e0:SetOperation(c76565322.ctop)
	c:RegisterEffect(e0)
	--RESET COUNTER_TRACKER
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e00:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e00:SetRange(LOCATION_SZONE+LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK+LOCATION_REMOVED)
	e00:SetCode(EVENT_TURN_END)
	e00:SetCountLimit(1)
	e00:SetLabelObject(e0)
	e00:SetOperation(c76565322.reset1)
	c:RegisterEffect(e00)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,76565322)
	e1:SetCondition(c76565322.sprcon)
	e1:SetOperation(c76565322.sprop)
	c:RegisterEffect(e1)
	--protection
	local ct1=Effect.CreateEffect(c)
	ct1:SetType(EFFECT_TYPE_SINGLE)
	ct1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	ct1:SetRange(LOCATION_MZONE)
	ct1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	ct1:SetCondition(c76565322.protcon)
	ct1:SetValue(1)
	c:RegisterEffect(ct1)
	local ctalt1=ct1:Clone()
	ctalt1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(ctalt1)
	--change position
	local ct2=Effect.CreateEffect(c)
	ct2:SetCategory(CATEGORY_POSITION)
	ct2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	ct2:SetCode(EVENT_SUMMON_SUCCESS)
	ct2:SetRange(LOCATION_MZONE)
	ct2:SetCountLimit(1,71565322)
	ct2:SetCondition(c76565322.poscon)
	ct2:SetTarget(c76565322.postg)
	ct2:SetOperation(c76565322.posop)
	c:RegisterEffect(ct2)
	local ctalt2=ct2:Clone()
	ctalt2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(ctalt2)
	local ctalt2_2=ct2:Clone()
	ctalt2_2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	ctalt2_2:SetTarget(c76565322.postg2)
	c:RegisterEffect(ctalt2_2)
	--atk boost
	local ct3=Effect.CreateEffect(c)
	ct3:SetType(EFFECT_TYPE_SINGLE)
	ct3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	ct3:SetRange(LOCATION_MZONE)
	ct3:SetCode(EFFECT_UPDATE_ATTACK)
	ct3:SetCondition(c76565322.boostcon)
	ct3:SetValue(1500)
	c:RegisterEffect(ct3)
	--quick effect
	local ct4=Effect.CreateEffect(c)
	ct4:SetDescription(aux.Stringid(76565322,15))
	ct4:SetCategory(CATEGORY_COUNTER+CATEGORY_DESTROY)
	ct4:SetType(EFFECT_TYPE_QUICK_O)
	ct4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	ct4:SetCode(EVENT_FREE_CHAIN)
	ct4:SetRange(LOCATION_MZONE)
	ct4:SetCountLimit(1,72565322)
	ct4:SetCondition(c76565322.qecon)
	ct4:SetTarget(c76565322.qetg)
	ct4:SetOperation(c76565322.qeop)
	c:RegisterEffect(ct4)
	--cannot special summon
	local efix=Effect.CreateEffect(c)
	efix:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	efix:SetType(EFFECT_TYPE_SINGLE)
	efix:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(efix)
end
--filters
function c76565322.mzfilter(c,tp)
	return c:IsControler(tp) and c:GetSequence()<5
end
function c76565322.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7555)
end
function c76565322.counterf(c)
	return c:IsFaceup() and c:GetCounter(0x1555)>0
end
function c76565322.posfilter(c,tp)
	return c:IsFaceup() and c:GetSummonPlayer()~=tp and c:IsCanTurnSet()
end
function c76565322.qefilter(c)
	return c:IsSetCard(0x7555) and c:GetType()==0x20002
end
--counter tracker
function c76565322.ctop(e,tp,eg,ep,ev,re,r,rp)
	local total=e:GetLabel()
	if ev>0 then
		total=total+ev 
		--check multiple effects
		if total>=2 then
			if e:GetHandler():GetFlagEffect(71565322)<=0 then
				e:GetHandler():RegisterFlagEffect(71565322,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(76565322,0))
			else
				e:GetHandler():RegisterFlagEffect(71165322,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(76565322,0))
			end
		end
		if total>=4 then
			if e:GetHandler():GetFlagEffect(72565322)<=0 then
				e:GetHandler():RegisterFlagEffect(72565322,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(76565322,1))
			else
				e:GetHandler():RegisterFlagEffect(72265322,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(76565322,1))
			end
		end
		if total>=6 then
			if e:GetHandler():GetFlagEffect(73565322)<=0 then
				e:GetHandler():RegisterFlagEffect(73565322,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(76565322,2))
			else
				e:GetHandler():RegisterFlagEffect(73365322,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(76565322,2))
			end
		end
		if total>=8 then
			if e:GetHandler():GetFlagEffect(74565322)<=0 then
				e:GetHandler():RegisterFlagEffect(74565322,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(76565322,3))
			else
				e:GetHandler():RegisterFlagEffect(74465322,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(76565322,3))
			end
		end
		---------
	end
	e:SetLabel(total)
end
function c76565322.exc(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()+2)
end
--reset counter tracker
function c76565322.reset1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
--spsummon proc
function c76565322.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(c76565322.sprfilter,tp,LOCATION_MZONE,0,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	return ft>-3 and rg:GetCount()>2 and (ft>0 or rg:IsExists(c76565322.mzfilter,ct,nil,tp))
end
function c76565322.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	rg=Duel.GetMatchingGroup(c76565322.sprfilter,tp,LOCATION_MZONE,0,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=nil
	if ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		g=rg:Select(tp,3,3,nil)
	elseif ft>-2 then
		local ct=-ft+1
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		g=rg:FilterSelect(tp,c76565322.mzfilter,ct,ct,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g2=rg:Select(tp,3-ct,3-ct,g)
		g:Merge(g2)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		g=rg:FilterSelect(tp,c76565322.mzfilter,3,3,nil,tp)
	end
	Duel.Destroy(g,REASON_COST)
end
--protection
function c76565322.protcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(71565322)>0 or e:GetHandler():GetFlagEffect(71165322)>0
end
--change position
function c76565322.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(72565322)>0 or e:GetHandler():GetFlagEffect(72265322)>0
end
function c76565322.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c76565322.posfilter,1,nil,tp) end
	local g=eg:Filter(c76565322.posfilter,nil,tp)
	Duel.SetTargetCard(g)
end
function c76565322.postg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return rp==1-tp and tc:IsFaceup() and tc:IsCanTurnSet() end
	Duel.SetTargetCard(tc)
end
function c76565322.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
--atk boost
function c76565322.boostcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(73565322)>0 or e:GetHandler():GetFlagEffect(73365322)>0
end
--quick effect
function c76565322.qecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(74565322)>0 or e:GetHandler():GetFlagEffect(74465322)>0
end
function c76565322.qetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c76565322.qefilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c76565322.qefilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(c76565322.qefilter),tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function c76565322.qeop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		Duel.BreakEffect()
		local op=Duel.GetOperatedGroup():GetFirst()
		--if not Duel.IsCanAddCounter(tp,0x1555,1,op) then return end
		if tc:AddCounter(0x1555,1) then
			if not tc:IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT) then return end
			tc:RemoveCounter(tp,0x1555,1,REASON_EFFECT)
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+76565322,e,0,tp,tp,0)
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
	