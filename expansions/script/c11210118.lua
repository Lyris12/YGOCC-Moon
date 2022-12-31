--Valkyr Spaziale
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--bigbang
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsPositive,2,2)
	c:EnableReviveLimit()
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drycon)
	e2:SetTarget(aux.DestroyTarget(nil,0,LOCATION_ONFIELD,1))
	e2:SetOperation(aux.DestroyOperation(nil,0,LOCATION_ONFIELD,1))
	c:RegisterEffect(e2)
	--ss
	c:DestroyedTrigger(false,1,CATEGORY_SEARCH+CATEGORY_TOHAND,true,{1,1},s.condition,nil,aux.SearchTarget(s.thf,1),aux.SearchOperation(s.thf,1))
end
function s.cf(c)
	return c:IsFaceup() and c:IsMonster(TYPE_BIGBANG)
end
function s.drycon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cf,1,nil) and not eg:IsContains(e:GetHandler())
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
function s.thf(c)
	return c:IsSetCard(0xbba)
end