--The Invocation of Moon
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.atkcon)
	e1:SetTarget(cid.atktg)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)
	--unequip
	local e1x=Effect.CreateEffect(c)
	e1x:SetDescription(aux.Stringid(id,1))
	e1x:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1x:SetType(EFFECT_TYPE_IGNITION)
	e1x:SetRange(LOCATION_SZONE)
	e1x:SetTarget(cid.sptg)
	e1x:SetOperation(cid.spop)
	c:RegisterEffect(e1x)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(cid.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(cid.thcon)
	e3:SetCost(cid.thcost)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
end
--EQUIP
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc,tc2=Duel.GetAttacker(),Duel.GetAttackTarget()
	if tc:IsControler(1-tp) then tc,tc2=tc2,tc end
	return tc and tc:IsControler(tp) and tc:IsRace(RACE_BEASTWARRIOR) and tc:IsLevelBelow(4) and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
		and aux.disfilter1(tc2)
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc1,tc2=Duel.GetAttacker(),Duel.GetAttackTarget()
	if tc1:IsControler(1-tp) then tc1,tc2=tc2,tc1 end
	local ct1,ct2=tc1:GetUnionCount()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and ct2==0 end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,tc1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc2,1,0,0)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc,tc2=Duel.GetAttacker(),Duel.GetAttackTarget()
	if tc:IsControler(1-tp) then tc,tc2=tc2,tc end
	if not c:IsRelateToEffect(e) then return end
	local ct1,ct2=tc:GetUnionCount()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not (ct2==0) or not tc:IsRelateToBattle() or not tc:IsControler(tp) then
		Duel.SendtoGrave(c,REASON_EFFECT)
	else
		if not Duel.Equip(tp,c,tc) then return end
		--Add Equip limit
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cid.eqlimit)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UNION_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(cid.eqlimit)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UNION_STATUS)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		if tc2 and tc2:IsFaceup() and ((tc2:IsType(TYPE_EFFECT) and not tc2:IsDisabled()) or tc2:IsType(TYPE_TRAPMONSTER)) and tc2:IsRelateToBattle() and tc2:IsControler(1-tp) then
			Duel.NegateRelatedChain(tc2,RESET_TURN_SET)
			local e1x=Effect.CreateEffect(c)
			e1x:SetType(EFFECT_TYPE_SINGLE)
			e1x:SetCode(EFFECT_DISABLE)
			e1x:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1x)
			local e2x=Effect.CreateEffect(c)
			e2x:SetType(EFFECT_TYPE_SINGLE)
			e2x:SetCode(EFFECT_DISABLE_EFFECT)
			e2x:SetValue(RESET_TURN_SET)
			e2x:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2x)
			if tc2:IsType(TYPE_TRAPMONSTER) then
				local e3x=Effect.CreateEffect(c)
				e3x:SetType(EFFECT_TYPE_SINGLE)
				e3x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3x:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3x:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc2:RegisterEffect(e3x)
			end
		end
	end
end
function cid.eqlimit(e,c)
	return e:GetOwner()==c
end

--UNEQUIP
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:RegisterFlagEffect(id,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end

--SEARCH
function cid.regop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) then return end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(id)>0
end
function cid.cfilter(c)
	return c:IsSetCard(0x5478) and c:IsAbleToRemoveAsCost()
end
function cid.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function cid.scfilter(c)
	return c:IsSetCard(0x5478) and c:IsAbleToHand() and not c:IsCode(id,id-8)
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end