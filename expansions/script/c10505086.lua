--Moonvale Tempest
function c10505086.initial_effect(c)
	  c:EnableReviveLimit()
	  --Send to grave
	  local e1=Effect.CreateEffect(c)
	  e1:SetDescription(aux.Stringid(10505086,0))
	  e1:SetCategory(CATEGORY_TOGRAVE)
	  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	  e1:SetProperty(EFFECT_FLAG_DELAY)
	  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	  e1:SetCondition(c10505086.tgcon)
	  e1:SetTarget(c10505086.tgtg)
	  e1:SetOperation(c10505086.tgop)
	  c:RegisterEffect(e1)
	  --destroy
	  local e2=Effect.CreateEffect(c)
	  e2:SetDescription(aux.Stringid(10505086,1))
	  e2:SetCategory(CATEGORY_DESTROY)
	  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	  e2:SetCode(EVENT_BATTLED)
	  e2:SetTarget(c10505086.target)
	  e2:SetOperation(c10505086.operation)
	  c:RegisterEffect(e2)
end
function c10505086.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
function c10505086.thfilter(c)
	return c:IsSetCard(0x1a4) or c:IsSetCard(0x1a5) and c:IsAbleToGrave()
end
function c10505086.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c10505086.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c10505086.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c10505086.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function c10505086.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local t=Duel.GetAttackTarget()
	if chk==0 then
		return (t==c and a:IsAbleToGrave())
			or (a==c and t~=nil and t:IsAbleToGrave())
	end
	local g=Group.CreateGroup()
	if a:IsRelateToBattle() then g:AddCard(a) end
	if t~=nil and t:IsRelateToBattle() then g:AddCard(t) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c10505086.operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	Duel.Destroy(rg,REASON_EFFECT)
end