--Leggenda Bushido Lupo Mannaro di Mezzanotte
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(id,1,0)
	aux.AddFusionProcFunRep(c,s.matfilter,3,false)
	local proc=aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	proc:SetValue(SUMMON_TYPE_FUSION)
	c:MustFirstBeSummoned()
	--protection
	c:UnaffectedProtection(s.efilter)
	--extra attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(aux.LocationGroupCond(s.ctfilter,LOCATION_REMOVED,LOCATION_REMOVED,3))
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_CANNOT_ATTACK)
	e1x:SetCondition(aux.NOT(aux.LocationGroupCond(s.ctfilter,LOCATION_REMOVED,LOCATION_REMOVED,2)))
	e1x:SetValue(1)
	c:RegisterEffect(e1x)
	--ss
	c:DestroyedTrigger(false,0,CATEGORY_SPECIAL_SUMMON,true,nil,
		aux.ByCardEffectCond(nil,TYPE_ST),
		nil,
		aux.SSTarget(aux.Filter(Card.IsSetCard,0x4b0),LOCATION_DECK,0,1,nil,nil,nil,nil,nil,POS_FACEUP_DEFENSE),
		aux.SSOperationMod(SPSUM_MOD_CHANGE_ATKDEF,aux.Filter(Card.IsSetCard,0x4b0),LOCATION_DECK,0,1,1,nil,{0,0},nil,nil,nil,nil,POS_FACEUP_DEFENSE)
	)
end
function s.matfilter(c)
	return c:IsMonster() and c:IsFusionSetCard(0x4b0)
end

function s.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and (tc:IsSummonType(SUMMON_TYPE_SPECIAL) or te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.ctfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x4b0)
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)-2
end