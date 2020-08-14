--created by ZEN, coded by Lyris & TaxingCorn117
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(cid.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.thtg)
	e2:SetOperation(cid.thop)
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
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x52f) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,500)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	if Duel.Damage(tp,500,REASON_EFFECT)~=0 and Duel.GetLP(tp)>0 and #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	return cid[tp]>2
end
function cid.thfilter(c)
	return c:IsSetCard(0x52f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end