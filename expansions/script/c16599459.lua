--Scriba dell'Organizzazione Angeli, Nesto
--Script by XGlitchy30
function c16599459.initial_effect(c)
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599459.efilter)
	c:RegisterEffect(e0)
	--synchro limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c16599459.synlimit)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,16599459)
	e2:SetLabel(0)
	e2:SetCondition(c16599459.drawcon)
	e2:SetCost(c16599459.drawcost)
	e2:SetTarget(c16599459.drawtg)
	e2:SetOperation(c16599459.drawop)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCondition(c16599459.thcon)
	e3:SetTarget(c16599459.thtg)
	e3:SetOperation(c16599459.thop)
	c:RegisterEffect(e3)
	--Register Damage
	local ge0=Effect.CreateEffect(c)
	ge0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	ge0:SetCode(EVENT_DAMAGE)
	ge0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_SZONE)
	ge0:SetLabelObject(e2)
	ge0:SetCondition(c16599459.regcon)
	ge0:SetOperation(c16599459.register)
	c:RegisterEffect(ge0)
	--Reset Damage
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge1:SetCode(EVENT_TURN_END)
	ge1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_SZONE)
	ge1:SetCountLimit(1)
	ge1:SetLabelObject(e2)
	ge1:SetCondition(c16599459.resetcon)
	ge1:SetOperation(c16599459.reset)
	c:RegisterEffect(ge1)
end
-----Register Damage-----
function c16599459.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local att=Duel.GetAttacker()
	local def=Duel.GetAttackTarget()
	return att and def and ep==tp and bit.band(r,REASON_BATTLE)~=0
		and ((att:IsControler(tp) and att:IsRace(RACE_FAIRY))
		or (def:IsControler(tp) and def:IsRace(RACE_FAIRY)))
end
function c16599459.register(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(101)
end
-----Reset Damage-----
function c16599459.resetcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()>0
end
function c16599459.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
--filters
function c16599459.cfilter(c)
	return c:IsSetCard(0x1559) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
		and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c16599459.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:GetAttack()==0
end
function c16599459.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function c16599459.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1559) and re:GetHandler():GetLevel()==e:GetHandler():GetLevel() and not re:GetHandler():IsType(TYPE_SYNCHRO)
		and not re:GetHandler():IsCode(16599459)
end
function c16599459.eq(c,card)
	return c==card
end
--target protection
function c16599459.efilter(e,re,rp)
	return ((re:GetHandler():GetLevel()>0 and re:GetHandler():IsLevelBelow(5)) or (re:GetHandler():GetRank()>0 and re:GetHandler():GetRank()<=5)) and rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--synchro limit
function c16599459.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_FAIRY)
end
--draw
function c16599459.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==101
end
function c16599459.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(c16599459.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c16599459.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,2,REASON_COST)
	end
end
function c16599459.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c16599459.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
--equip
function c16599459.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsRace(RACE_FAIRY) and e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
end
function c16599459.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and c16599459.eqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c16599459.eqfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c16599459.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c16599459.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local c=e:GetHandler()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	--update atk
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(tc:GetTextDefense())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	--activation limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetValue(c16599459.aclimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end