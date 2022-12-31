--The Lost Sarcophagus
local id,cod=23251025,c23251025
function cod.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cod.target)
	e1:SetOperation(cod.activate)
	c:RegisterEffect(e1)
	if not cod.global_check then
		cod.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_DECK)
		ge1:SetLabelObject(e1)
		ge1:SetOperation(cod.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function cod.checkop(e,tp,eg,ep,ev,re,r,rp)
	local label=0
	local c=e:GetHandler()
	if c:GetFlagEffectLabel(id) then
		label=c:GetFlagEffectLabel(id)
		c:ResetFlagEffect(id)
	end
	if not c:IsPreviousLocation(LOCATION_DECK) then
		c:RegisterFlagEffect(id,RESET_EVENT+0x166000,0,0,label+1)
	end
end
function cod.spfilter(c,e,tp)
	return c:IsSetCard(0xd3e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cod.cfilter(c,e)
	return c:IsSetCard(0xd3e) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local label=0
	if e:GetHandler():GetFlagEffectLabel(id) then
		label=e:GetHandler():GetFlagEffectLabel(id)
	end
	local b1=e:GetHandler():IsAbleToDeck()
	local b2=Duel.IsPlayerCanDraw(tp,1) and label>=1
	local b3=Duel.IsPlayerCanSpecialSummon(tp) and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and label>=2
	local b4=Duel.IsExistingTarget(cod.cfilter,tp,LOCATION_MZONE,0,1,nil,e) and label>=3
	local op=0
	if b1 and (b2 or b3 or b4) then
		local m={}
		local n={}
		local ct=1
		if b1 then m[ct]=aux.Stringid(id,0) n[ct]=1 ct=ct+1 end
		if b2 then m[ct]=aux.Stringid(id,1) n[ct]=2 ct=ct+1 end
		if b3 then m[ct]=aux.Stringid(id,2) n[ct]=3 ct=ct+1 end
		if b4 then m[ct]=aux.Stringid(id,3) n[ct]=4 ct=ct+1 end
		local sp=Duel.SelectOption(tp,table.unpack(m))
		op=n[sp+1]
	end
	e:SetLabel(op)
	if op==2 then
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		e:SetProperty(0)
		e:SetCategory(CATEGORY_DRAW)
	elseif op==3 then
		e:SetProperty(0)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	elseif op==4 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,cod.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(0)
	else
		e:SetProperty(0)
		e:SetCategory(CATEGORY_TODECK)
	end
end
function cod.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==2 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	elseif e:GetLabel()==3 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			or not Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	elseif e:GetLabel()==4 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCondition(cod.remcon)
			e1:SetValue(LOCATION_REMOVED)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,4))
			e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e2:SetRange(LOCATION_REMOVED)
			e2:SetCountLimit(1)
			e2:SetTarget(cod.sptg)
			e2:SetOperation(cod.spop)
			e2:SetReset(RESET_EVENT+0x1660000)
			tc:RegisterEffect(e2)
		end
	else
		if c:IsRelateToEffect(e) then
			c:CancelToGrave()
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		end
	end
end
function cod.remcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp))
end
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end