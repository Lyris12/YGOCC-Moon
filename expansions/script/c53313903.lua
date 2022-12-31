--Mysterious Ball
function c53313903.initial_effect(c)
	--spsummon proc
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(53313903,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetCountLimit(1,53313903)
	e0:SetCondition(c53313903.spsumcon)
	e0:SetOperation(c53313903.spsumop)
	c:RegisterEffect(e0)
	--multi attack
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetDescription(aux.Stringid(53313903,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,53323903)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c53313903.distg)
	e1:SetOperation(c53313903.disop)
	c:RegisterEffect(e1)
	--place pandemonium monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53313903,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,53333903)
	e2:SetCondition(c53313903.thcon)
	e2:SetTarget(c53313903.thtg)
	e2:SetOperation(c53313903.thop)
	c:RegisterEffect(e2)
end
--filters
function c53313903.spsumfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and not c:IsDisabled() and (not c:IsType(TYPE_NORMAL) or c:GetOriginalType()&TYPE_EFFECT~=0) and ft>0
end
function c53313903.actfilter(c,tp)
	return c:IsSetCard(0xcf6) and c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden()
			and not Duel.IsExistingMatchingCard(c53313903.excfilter,tp,LOCATION_SZONE,0,1,c)
			and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()))
end
function c53313903.excfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsFaceup()
end
--spsummon proc
function c53313903.spsumcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>0 and Duel.IsExistingMatchingCard(c53313903.spsumfilter,tp,LOCATION_MZONE,0,1,nil,ft)
end
function c53313903.spsumop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c53313903.spsumfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e2)
		if g:GetFirst():IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			g:GetFirst():RegisterEffect(e3)
		end
	end
end
--multi attack
function c53313903.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
end
function c53313903.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsType,nil,TYPE_MONSTER)
		if ct>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
			e1:SetValue(ct-1)
			c:RegisterEffect(e1)
		end
	end
end
--place pandemonium monster
function c53313903.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)))
end
function c53313903.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313903.actfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,tp) end
end
function c53313903.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53313903.actfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Card.SetCardData(tc,CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		if not tc:IsLocation(LOCATION_SZONE) then
			local edcheck=0
			if tc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
			Card.SetCardData(tc,CARDDATA_TYPE,TYPE_MONSTER+TYPE_EFFECT+edcheck+aux.GetOriginalPandemoniumType(tc))
		else
			tc:RegisterFlagEffect(726,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CANNOT_DISABLE,1)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_DISABLE_PANDEMONIUM_SUMMON)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end