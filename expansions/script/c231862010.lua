--created by ZEN, coded by TaxingCorn117
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddLinkProcedure(c,nil,2,2,cid.lcheck)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(math.floor(id/100),1))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(cid.rmcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.rmtg)
	e2:SetOperation(cid.rmop)
	c:RegisterEffect(e2)
	if cid.counter==nil then
		cid.counter=true
		cid[0]=0
		cid[1]=0
		cid[2]=0
		cid[3]=0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(cid.resetcount)
		Duel.RegisterEffect(e2,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_DAMAGE)
		e3:SetOperation(cid.addcount)
		Duel.RegisterEffect(e3,0)
	end
end
function cid.resetcount(e,tp,eg,ep,ev,re,r,rp)
	local p=2+Duel.GetTurnPlayer()
	if cid[p]>0 and cid[3-p]>0 then cid[p]=0 cid[3-p]=0 end
	if cid[p]>1 then cid[p-2]=0 cid[p]=0 end
	cid[p]=cid[p]+1
end
function cid.addcount(e,tp,eg,ep,ev,re,r,rp)
	cid[ep]=cid[ep]+1
end
function cid.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x52f) and not g:IsExists(Card.IsLinkCode,1,nil,id)
end
function cid.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x52f) and c:IsLevel(lv) and not c:IsType(TYPE_LINK) and (c:IsLocation(LOCATION_DECK) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,100)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.TossDice(tp,1)
	local g=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp,dc)
	if Duel.Damage(tp,dc*100,REASON_EFFECT)~=0 and Duel.GetLP(tp)>0 and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cid.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return cid[tp]>2
end
function cid.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function cid.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	local g=Duel.GetMatchingGroup(cid.rmfilter,tp,0,LOCATION_ONFIELD,exc)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.rmfilter,tp,0,LOCATION_ONFIELD,1,1,exc)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end