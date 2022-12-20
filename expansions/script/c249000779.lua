--Majestic Protector Knight
function c249000779.initial_effect(c)
	c:EnableCounterPermit(0x2b)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--special summon (battle damage)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40640057,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c249000779.spcon)
	e1:SetCost(c249000779.spcost)
	e1:SetTarget(c249000779.sptg)
	e1:SetOperation(c249000779.spop)
	c:RegisterEffect(e1)
	--effect damage special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetOperation(c249000779.spop2)
	c:RegisterEffect(e2)
	--recover
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c249000779.rectg)
	e3:SetOperation(c249000779.recop)
	c:RegisterEffect(e3)
	--check damage
	local ch=Effect.CreateEffect(c)
	ch:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ch:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE)
	ch:SetRange(LOCATION_MZONE)
	ch:SetCode(EVENT_DAMAGE)
	ch:SetOperation(c249000779.checkop)
	ch:SetLabelObject(e3)
	c:RegisterEffect(ch)
	--avoid damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetLabelObject(e3)
	e4:SetValue(c249000779.damval)
	c:RegisterEffect(e4)
	--remove spell counter
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_DAMAGE_STEP_END)
	e5:SetCondition(aux.dsercon)
	e5:SetOperation(c249000779.rcounterop)
	c:RegisterEffect(e5)
	--battle indestructable
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e6:SetCondition(c249000779.indescon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	--immune effect
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c249000779.immunecon)
	e7:SetValue(c249000779.efilter)
	c:RegisterEffect(e7)
	--cannot tribute
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_UNRELEASABLE_SUM)
	e8:SetValue(1)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e9)
	--cannot be ED material
	aux.CannotBeEDMaterial(c,nil,LOCATION_MZONE,false,nil)
end
function c249000779.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp) >= Duel.GetLP(tp) and Duel.GetFlagEffect(tp,249000779)==0 and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function c249000779.spcostfilter(c)
	return c:IsSetCard(0x103F) and c:IsAbleToDeckOrExtraAsCost() and not (c:IsLocation(LOCATION_REMOVED) and c:IsFacedown())
end
function c249000779.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000779.spcostfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c249000779.spcostfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,3,3,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function c249000779.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c249000779.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
		e1:SetReset(RESET_CHAIN)
		c:RegisterEffect(e1)
		Duel.SpecialSummon(c,SUMMMON_TYPE_LINK,tp,tp,true,false,POS_FACEUP)
		c:CompleteProcedure()
		c:AddCounter(0x2b,Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD,nil)+1)
		Duel.RegisterFlagEffect(tp,249000779,0,0,1)
	end
end
function c249000779.spop2(e,tp,eg,ep,ev,re,r,rp)
 	local c=e:GetHandler()
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	local ex2,cg2,ct2,cp2,cv2=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	if not (ex and (cp==tp or cp==PLAYER_ALL) and cv >= Duel.GetLP(tp) or
	(ex2 and (cp2==tp or cp==PLAYER_ALL) and Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_RECOVER) and cv2 >= Duel.GetLP(tp))) then return end
	if e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,true,false) and Duel.IsExistingMatchingCard(c249000779.spcostfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,3,nil)
		and Duel.GetFlagEffect(tp,249000779)==0 and Duel.SelectYesNo(tp,aux.Stringid(9287078,0)) then
		local g=Duel.SelectMatchingCard(tp,c249000779.spcostfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,3,3,nil)
		Duel.SendtoDeck(g,nil,2,REASON_COST)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
		e1:SetReset(RESET_CHAIN)
		c:RegisterEffect(e1)
		Duel.SpecialSummon(c,SUMMON_TYPE_LINK,tp,tp,true,false,POS_FACEUP)
		c:CompleteProcedure()
		c:AddCounter(0x2b,Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD,nil)+1)
		Duel.RegisterFlagEffect(tp,249000779,0,0,1)
	end
end
function c249000779.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.floor(e:GetLabel()/2))
end
function c249000779.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,math.floor(e:GetLabel()/2),REASON_EFFECT)
	e:SetLabel(0)
end
function c249000779.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	local lp=Duel.GetLP(tp)
	if lp <=100 then
		e:GetLabelObject():SetLabel(val+e:GetLabelObject():GetLabel())
		return 0
	elseif lp - val < 100 then
		local val2=val - math.abs(lp - val) - 100
		e:GetLabelObject():SetLabel(val - val2 + e:GetLabelObject():GetLabel())
		return val2
	else
		return val
	end
end
function c249000779.checkop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(ev+e:GetLabelObject():GetLabel())
end
function c249000779.rcounterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RemoveCounter(tp,0x2b,1,REASON_EFFECT)
end
function c249000779.indescon(e)
	return e:GetHandler():GetCounter(0x2b)>0
end
function c249000779.immunecon(e)
	return e:GetHandler():GetCounter(0x2b)>1
end
function c249000779.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end