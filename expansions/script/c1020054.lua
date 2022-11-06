--created by Jake
--Leggenda Bushido Ciclope

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACES_BEASTS),aux.NonTuner(nil),1)
	c:MustFirstBeSummoned(SUMMON_TYPE_SYNCHRO)
	--protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.efilter)
	c:RegisterEffect(e0)
	--force opponent to send to GY
	local e1=c:DestroysByBattleTrigger(false,nil,0,CATEGORY_TOGRAVE,true,true,
		nil,
		nil,
		s.tgtg,
		s.tgop
	)
	local e2=e1:Clone()
	e2:Desc(1)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and (tc:IsSummonType(SUMMON_TYPE_SPECIAL) or te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE+LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE+LOCATION_HAND)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE+LOCATION_HAND,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,1,nil)
		if #sg>0 then
			if sg:GetFirst():IsLocation(LOCATION_HAND) then
				Duel.ConfirmCards(tp,sg)
			else
				Duel.HintSelection(sg)
			end
			Duel.SendtoGrave(sg,REASON_RULE)
		end
	end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end