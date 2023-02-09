--Incantatrice Pandemonium
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--set
	local p1=Effect.CreateEffect(c)
	p1:SetDescription(aux.Stringid(id,0))
	p1:SetCategory(CATEGORY_DESTROY)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetCountLimit(1)
	p1:SetCondition(aux.PandActCheck)
	p1:SetCost(cid.setcost)
	p1:SetTarget(cid.settg)
	p1:SetOperation(cid.setop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1)
	--MONSTER EFFECTS
	--change aftersummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_PANDEMONIUM_SUMMON_AFTERMATH)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(cid.replacetg)
	e1:SetOperation(cid.replaceproc)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetTarget(cid.drytg)
	e2:SetOperation(cid.dryop)
	c:RegisterEffect(e2)
end
--SET
function cid.cfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cid.setfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER)
end
-----------
function cid.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(cid.setfilter,nil,LOCATION_EXTRA+LOCATION_GRAVE)(nil,e,tp,eg,ep,ev,re,r,rp)
		and Duel.IsExistingMatchingCard(cid.setfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) 
	end
	local lg=Duel.GetMatchingGroup(cid.setfilter,tp,LOCATION_GRAVE,0,nil)
	if #lg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,lg,1,0,0)
	end
	if e:GetHandler():IsDestructable(e) and e:GetHandler():IsRelateToEffect(e) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	end
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 
	or not aux.PandSSetCon(cid.setfilter,nil,LOCATION_EXTRA+LOCATION_GRAVE)(nil,e,tp,eg,ep,ev,re,r,rp) then 
		return 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.PandSSetFilter(cid.setfilter,LOCATION_EXTRA+LOCATION_GRAVE)),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	if g:GetCount()>0 then
		aux.PandSSet(g,REASON_EFFECT,aux.GetOriginalPandemoniumType(g:GetFirst()))(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
--CHANGE AFTERSUMMON PROC
function cid.replacetg(e,c)
	return c:GetFlagEffect(726)>0
end
function cid.replaceproc(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
--DESTROY
function cid.dryfilter(c,e)
	return c:IsFaceup() and c:IsDestructable(e)
end
------------
function cid.drytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dryfilter,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,e:GetHandler(),e) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
function cid.dryop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,cid.dryfilter,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,1,e:GetHandler(),e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end