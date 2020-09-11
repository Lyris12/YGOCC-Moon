--Brant, Cascad Combatant
--Script by XGlitchy30
function c31231313.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),4,2)
	c:EnableReviveLimit()
	--atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetDescription(aux.Stringid(31231313,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1,31231313)
	e1:SetCondition(c31231313.zrcon)
	e1:SetCost(c31231313.zrcost)
	e1:SetOperation(c31231313.zrop)
	c:RegisterEffect(e1)
	--column destruction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31231313,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c31231313.clcon)
	e2:SetTarget(c31231313.cltg)
	e2:SetOperation(c31231313.clop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31231313,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,31231213)
	e3:SetCost(c31231313.hspcost)
	e3:SetTarget(c31231313.hsptg)
	e3:SetOperation(c31231313.hspop)
	c:RegisterEffect(e3)
end
--filters
function c31231313.rfilter(c)
	return c:IsRace(RACE_AQUA) and c:IsAbleToRemoveAsCost()
end
--atk/def
function c31231313.zrcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup()
end
function c31231313.zrcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c31231313.zrop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		bc:RegisterEffect(e2)
	end
end
--column destruction
function c31231313.clcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsType(TYPE_MONSTER)
end
function c31231313.cltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	--detect column
	local zone=bc:GetPreviousSequence()
	local z=2^zone|2^(zone<5 and zone or (zone==5 and 1 or 3)+8)
	if zone==1 or zone==5 then z=z|0x400022
	elseif zone==3 or zone==6 then z=z|0x200048 end
	e:SetLabel(z)
	--
	local g=Duel.GetCardsInZone(1-tp,z)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c31231313.clop(e,tp,eg,ep,ev,re,r,rp)
	local z=e:GetLabel()
	local g=Duel.GetCardsInZone(1-tp,z)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--spsummon
function c31231313.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31231313.rfilter,tp,LOCATION_GRAVE,0,4,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c31231313.rfilter,tp,LOCATION_GRAVE,0,4,4,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c31231313.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31231313.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end