--Multiversal Markshall
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigPandemoniumType(c)
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsType,TYPE_PENDULUM),aux.FilterBoolFunction(Card.IsType,TYPE_PANDEMONIUM),1,1,true)
	--activate
	local p1=Effect.CreateEffect(c)
	p1:GLString(0)
	p1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	p1:SetType(EFFECT_TYPE_IGNITION)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCountLimit(1,id)
	p1:SetCondition(aux.PandActCheck)
	p1:SetTarget(cid.dptg)
	p1:SetOperation(cid.dpop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,true,TYPE_EFFECT+TYPE_FUSION)
	--name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(63553466)
	c:RegisterEffect(e1)
	--activate cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(cid.costcon)
	e2:SetCost(cid.costchk)
	e2:SetTarget(cid.costtg)
	e2:SetOperation(cid.costop)
	c:RegisterEffect(e2)
	--accumulate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(0x10000000+id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	--search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(cid.thcon)
	e4:SetCost(cid.thcost)
	e4:SetTarget(cid.thtg)
	e4:SetOperation(cid.thop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(cid.valcheck)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
--ACTIVATE
function cid.dpfilter(c,tp,typ,cc)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsType(typ)
		and ((typ==TYPE_PANDEMONIUM and Duel.GetMZoneCount(tp,Group.FromCards(c,cc))>0) or Duel.IsExistingMatchingCard(cid.dpfilter,tp,LOCATION_MZONE,0,1,c,tp,TYPE_PANDEMONIUM,c))
end
--------
function cid.dptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dpfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp,TYPE_PENDULUM,nil)
		 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x7a4,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM+TYPE_FUSION,2700,2900,8,RACE_MACHINE,ATTRIBUTE_FIRE)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.dpop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,cid.dpfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,TYPE_PENDULUM,nil)
	local g2=Duel.SelectMatchingCard(tp,cid.dpfilter,tp,LOCATION_MZONE,0,1,1,g1,tp,TYPE_PANDEMONIUM,g1:GetFirst())
	g2:Merge(g1)
	if g1:GetCount()==2 then
		Duel.HintSelection(g1)
		if Duel.Destroy(g1,REASON_EFFECT)~=0 then
			if not e:GetHandler():IsRelateToEffect(e) or not e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP) or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,2000,0,4,RACE_THUNDER,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			e:GetHandler():AddMonsterAttribute(TYPE_EFFECT+TYPE_PANDEMONIUM+TYPE_FUSION)
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
--ACTIVATE COST
function cid.costcon(e)
	return Duel.GetFlagEffect(1-e:GetHandlerPlayer(),id+100)<=0
end
function cid.costchk(e,te_or_c,tp)
	local ct=Duel.GetFlagEffect(tp,id)
	return Duel.CheckLPCost(tp,ct*2000) 
end
function cid.costtg(e,te,tp)
	if not te:IsActiveType(TYPE_TRAP) then return false end
	return true
end
function cid.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,2000)
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
end
--SEARCH
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function cid.cfilter(c)
	return c:IsSetCard(0x7a4) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cid.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cid.thfilter(c,lab)
	return (c:IsType(TYPE_PANDEMONIUM) or (lab==100 and c:IsType(TYPE_TRAP) and c:IsSetCard(0x7a4))) and c:IsAbleToHand()
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cid.mfilter(c)
	return not c:IsSetCard(0x7a4)
end
function cid.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	if not g:IsExists(cid.mfilter,1,nil) then
		flag=100
	end
	e:GetLabelObject():SetLabel(flag)
end