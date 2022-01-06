--Divexplorer Expedition
local ref,id=GetID()
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_END_PHASE)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
end

function ref.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function ref.rmfilter(c)
	return c:IsSetCard(0x72e) and c:IsAbleToRemove()
end
function ref.retfilter(c)
	return c:IsSetCard(0x72e) and c:IsFaceup()
end
function ref.lvfilter(c)
	return c:IsSetCard(0x72e) and c:IsFaceup() and c:IsLevelAbove(0)
end
ref.var1=bit.lshift(1,0)
ref.var2=bit.lshift(1,1)
ref.var3=bit.lshift(1,2)
function ref.actloop(e,con1,con2,con3)
	local val=e:GetLabel()
	local optdesc={}
	local optbit={}
	local optct=0
	if con1 and (bit.band(val,ref.var1)~=ref.var1) then
		table.insert(optdesc,aux.Stringid(id,0))
		table.insert(optbit,ref.var1)
		optct=optct+1
	end
	if con2 and (bit.band(val,ref.var2)~=ref.var2) then
		table.insert(optdesc,aux.Stringid(id,1))
		table.insert(optbit,ref.var2)
		optct=optct+1
	end
	if con3 and (bit.band(val,ref.var3)~=ref.var3) then
		table.insert(optdesc,aux.Stringid(id,2))
		table.insert(optbit,ref.var3)
		optct=optct+1
	end
	if optct > 0 then
		local opt=Duel.SelectOption(e:GetHandlerPlayer(),table.unpack(optdesc))
		val=bit.bor(val,optbit[opt+1])
		e:SetLabel(val)
	end
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local con1 = Duel.GetCurrentPhase()~=PHASE_DAMAGE and Duel.IsExistingTarget(ref.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	local con2 = Duel.IsExistingMatchingCard(ref.retfilter,tp,LOCATION_REMOVED,0,1,nil)
	and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local con3 = Duel.IsExistingMatchingCard(ref.retfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if chkc then
		local opt=e:GetLabel()
		if opt==ref.var1 then return ref.rmfilter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) end
		if opt==ref.var2 then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
		if opt==ref.var3 then return chkc:IsFaceup() and ref.retfilter(chkc) and chkc:IsControler(tp) end
		return false
	end
	if chk==0 then return con1 or con2 or con3 end
	e:SetLabel(0)
	ref.actloop(e,con1,con2,con3)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=3 then ref.actloop(e,con1,con2,con3) end
	
	local property=e:GetProperty()
	local val=e:GetLabel()
	local cat=0
	if (bit.band(val,ref.var1)==ref.var1) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g1=Duel.SelectTarget(tp,ref.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
		cat=cat+CATEGORY_REMOVE
	end
	if (bit.band(val,ref.var2)==ref.var2) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local cg=Duel.SelectMatchingCard(tp,ref.retfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
		Duel.SendtoGrave(cg,REASON_COST)
		local g2=Duel.SelectTarget(tp,ref.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		cat=cat+CATEGORY_ATKCHANGE
		local tc=g2:GetFirst()
		if tc:IsType(TYPE_MONSTER) and tc:IsAttribute(cg:GetFirst():GetAttribute()) then
			cat=cat+CATEGORY_DISABLE
			Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
		end
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,0)
		Duel.SetTargetParam(tc:GetAttribute())
	end
	if (bit.band(val,ref.var3)==ref.var3) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g3=Duel.SelectTarget(tp,ref.retfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g3,1,0,0)
	end
	--[[if val==3 then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
		local lv=Duel.AnnounceLevel(tp,1,8,nil)
		Duel.SetTargetParam(lv)
	end]]
	e:SetCategory(cat)
	e:SetLabel(val)
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local val=e:GetLabel()
	if (bit.band(val,ref.var1)==ref.var1) then
		--Debug.Message("Banishing")
		local ex,g1=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
		g1=g1:Filter(Card.IsRelateToEffect,nil,e)
		--local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
	end
	if (bit.band(val,ref.var2)==ref.var2) then
		--Debug.Message("ATK Change")
		local ex,g2=Duel.GetOperationInfo(0,CATEGORY_ATKCHANGE)
		local tc=g2:GetFirst()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			if (bit.band(e:GetCategory(),CATEGORY_DISABLE)==CATEGORY_DISABLE) and tc:IsAttribute(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)) then
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE)
				e2:SetValue(RESET_TURN_SET)
				tc:RegisterEffect(e2)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_DISABLE_EFFECT)
				e3:SetValue(RESET_TURN_SET)
				tc:RegisterEffect(e3)
				Duel.AdjustInstantly(tc)
			end
		end
	end
	if (bit.band(val,ref.var3)==ref.var3) then
		--Debug.Message("Protection")
		local ex,g3=Duel.GetOperationInfo(0,CATEGORY_LEAVE_GRAVE)
		local tc=g3:GetFirst()
		if tc:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_INDESTRUCTABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
	if not c:IsRelateToEffect(e) then return end
	if c:IsSSetable(true) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
