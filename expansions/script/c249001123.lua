--Number 0: Angel of Infinite Life
function c249001123.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),7,3)
	c:EnableReviveLimit()
	--special summon (battle damage)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(2)
	e1:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c249001123.spcon)
	e1:SetCost(c249001123.spcost)
	e1:SetTarget(c249001123.sptg)
	e1:SetOperation(c249001123.spop)
	c:RegisterEffect(e1)
	--effect damage special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetOperation(c249001123.spop2)
	c:RegisterEffect(e2)
	--recover
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c249001123.rectg)
	e3:SetOperation(c249001123.recop)
	c:RegisterEffect(e3)
	--check damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetOperation(c249001123.checkop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	--cannot lose
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_LOSE_KOISHI)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(1,0)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--indestructable by effect
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e6:SetCondition(c249001123.efcon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	--cannot be target
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c249001123.efcon)
	e7:SetValue(aux.tgoval)
	c:RegisterEffect(e7)
	--Cost Change
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_LPCOST_CHANGE)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(1,0)
	e8:SetValue(0)
	c:RegisterEffect(e8)
	--Draw 2
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_DRAW_COUNT)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e9:SetRange(LOCATION_MZONE)
	e9:SetTargetRange(1,0)
	e9:SetValue(2)
	c:RegisterEffect(e9)
	--cannot negate
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetCode(EFFECT_CANNOT_DISABLE)
	e10:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e10:SetRange(0xFF)
	c:RegisterEffect(e10)
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_CANNOT_DISEFFECT)
	e11:SetRange(0xFF)
	e11:SetValue(c249001123.efilter)
	c:RegisterEffect(e11)
	--destroy replace
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e12:SetCode(EFFECT_DESTROY_REPLACE)
	e12:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e12:SetRange(LOCATION_MZONE)
	e12:SetTarget(c249001123.reptg)
	c:RegisterEffect(e12)
end
c249001123.xyz_number=0
function c249001123.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp) >= Duel.GetLP(tp) and Duel.GetFlagEffect(tp,249001123)==0
end
function c249001123.spcostfilter(c)
	return c:IsSetCard(0x73) and c:IsAbleToDeckOrExtraAsCost() and not (c:IsLocation(LOCATION_REMOVED) and c:IsFacedown())
end
function c249001123.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001123.spcostfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c249001123.spcostfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,3,3,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function c249001123.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c249001123.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local mg=Group.CreateGroup()
		local tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			mg:AddCard(tc2)
			Duel.Overlay(c,tc2)
		end
		tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			mg:AddCard(tc2)
			Duel.Overlay(c,tc2)
		end
		tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			mg:AddCard(tc2)
			Duel.Overlay(c,tc2)
		end
		if mg:GetCount() > 0 then c:SetMaterial(mg) end
		Duel.SpecialSummon(c,SUMMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		c:CompleteProcedure()
		Duel.RegisterFlagEffect(tp,249001123,0,0,1)
	end
end
function c249001123.spop2(e,tp,eg,ep,ev,re,r,rp)
 	local c=e:GetHandler()
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	local ex2,cg2,ct2,cp2,cv2=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	if not (ex and (cp==tp or cp==PLAYER_ALL) and cv >= Duel.GetLP(tp) or
	(ex2 and (cp2==tp or cp==PLAYER_ALL) and Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_RECOVER) and cv2 >= Duel.GetLP(tp))) then return end
	if e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.IsExistingMatchingCard(c249001123.spcostfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,3,nil)
		and Duel.GetFlagEffect(tp,249001123)==0 and Duel.SelectYesNo(tp,2) then
		local g=Duel.SelectMatchingCard(tp,c249001123.spcostfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,3,3,nil)
		Duel.SendtoDeck(g,nil,2,REASON_COST)
		local mg=Group.CreateGroup()
		local tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			mg:AddCard(tc2)
			Duel.Overlay(c,tc2)
		end
		tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			mg:AddCard(tc2)
			Duel.Overlay(c,tc2)
		end
		tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			mg:AddCard(tc2)
			Duel.Overlay(c,tc2)
		end
		if mg:GetCount() > 0 then c:SetMaterial(mg) end
		Duel.SpecialSummon(c,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		c:CompleteProcedure()
		Duel.RegisterFlagEffect(tp,249001123,0,0,1)
	end
end
function c249001123.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.floor(e:GetLabel()/2))
end
function c249001123.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,math.floor(e:GetLabel()/2),REASON_EFFECT)
	e:SetLabel(0)
end
function c249001123.checkop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(ev+e:GetLabelObject():GetLabel())
end
function c249001123.efcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
function c249001123.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end
function c249001123.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end