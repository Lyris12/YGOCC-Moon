--Lamaccino dell'Alba - Bandito
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x613),2,true)
	--salvage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:HOPT()
	e1:SetCondition(s.thcon)
	e1:SetTarget(aux.SearchTarget({s.thfil,GFILTER_DIFFERENT_NAMES},1,LOCATION_GRAVE))
	e1:SetOperation(aux.SearchOperation({s.thfil,GFILTER_DIFFERENT_NAMES},1,3,LOCATION_GRAVE))
	c:RegisterEffect(e1)
	--pop
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(s.descon)
	e2:SetCost(aux.DiscardCost())
	e2:SetTarget(aux.DestroyTarget())
	e2:SetOperation(aux.DestroyOperation())
	c:RegisterEffect(e2)
	--discard
	c:SentToGYTrigger(false,2,CATEGORY_HANDES,EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DDD,true,nil,nil,aux.DiscardTarget(nil,1,2),aux.DiscardOperation(nil,1,2))
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=113
end
function s.thfil(c)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) 
end