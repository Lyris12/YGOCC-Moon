--Terradicazione Fiamma Comandante, Meteoimperatore
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigPandemoniumType(c)
	--PANDE: Summon Restriction
	local p0=Effect.CreateEffect(c)
	p0:SetType(EFFECT_TYPE_FIELD)
	p0:SetRange(LOCATION_SZONE)
	p0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	p0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	p0:SetTargetRange(1,0)
	p0:SetCondition(aux.PandActCheck)
	p0:SetTarget(s.psplimit)
	c:RegisterEffect(p0)
	--PANDE: Draw, damage, destroy
	local p1=Effect.CreateEffect(c)
	p1:Desc(0)
	p1:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE+CATEGORY_DESTROY)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCountLimit(1,id)
	p1:SetCondition(aux.PandActCheck)
	p1:SetCost(s.drawcost)
	p1:SetTarget(s.drawtg)
	p1:SetOperation(s.drawop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1)
	--SpSummon Proc
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	--Add Names
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(20181407)
	c:RegisterEffect(e2)
	--Send to GY + (Search OR Activate Pandemonium)
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id+100)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Mill
	local e4=Effect.CreateEffect(c)
	e4:Desc(5)
	e4:SetCategory(CATEGORY_DECKDES+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCountLimit(1,id+200)
	e4:SetTarget(s.target2)
	e4:SetOperation(s.operation2)
	c:RegisterEffect(e4)
end
function s.psplimit(e,c,tp,sumtp,sumpos)
	return not c:IsRace(RACE_DINOSAUR) and (sumtp&SUMMON_TYPE_PANDEMONIUM)==SUMMON_TYPE_PANDEMONIUM
end

function s.drcostfilter(c)
	return c:IsMonster() and c:IsRace(RACE_DINOSAUR) and c:IsAbleToGraveAsCost() and c:NotInExtraOrFaceup()
end
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.drcostfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.drcostfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.Draw(tp,1,REASON_EFFECT)>0 and Duel.Damage(1-tp,500,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end

function s.rgchk(c)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsSetCard(0x9b5)
end
function s.rgpfilter(c)
	return c:IsFaceup() and s.rgchk(c) and c:IsReleasable()
end
function s.mzctcheckrel(g,tp)
	--local gx=g:Filter(Card.IsLocation,nil,LOCATION_SZONE+LOCATION_EXTRA)
	local gn=g:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_SZONE+LOCATION_EXTRA)
	return Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroup(tp,Auxiliary.IsInGroup,#gn,nil,gn) 
end
function s.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp):Filter(s.rgchk,nil)
	local rgp=Duel.GetMatchingGroup(s.rgpfilter,tp,LOCATION_SZONE+LOCATION_EXTRA,0,nil)
	rg:Merge(rgp)
	return rg:CheckSubGroup(s.mzctcheckrel,3,3,tp)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetReleaseGroup(tp):Filter(s.rgchk,nil)
	local rgp=Duel.GetMatchingGroup(s.rgpfilter,tp,LOCATION_SZONE+LOCATION_EXTRA,0,nil)
	rg:Merge(rgp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=rg:SelectSubGroup(tp,s.mzctcheckrel,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE-RESET_TOFIELD)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(7)
	c:RegisterEffect(e1)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.tgfilter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(s.opfilter,tp,LOCATION_DECK,0,1,c,e,tp,eg,ep,ev,re,r,rp)
end
function s.opfilter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsSetCard(0x9b5) and (c:IsAbleToHand() or (c:IsMonster(TYPE_PANDEMONIUM) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp))) 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local exc = (e:GetLabel()==1) and nil or e:GetHandler()
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,exc,e,tp,eg,ep,ev,re,r,rp)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc0=tg:GetFirst()
	if tc0 and Duel.SendtoGrave(tc0,REASON_EFFECT)~=0 and tc0:IsLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local g=Duel.SelectMatchingCard(tp,s.opfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			if tc and tc:IsAbleToHand() and (not (tc:IsMonster(TYPE_PANDEMONIUM) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp)) or Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0) then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				aux.PandAct(tc)(e,tp,eg,ep,ev,re,r,rp)
				local te=tc:GetActivateEffect()
				te:UseCountLimit(tp,1,true)
				local tep=tc:GetControler()
				local cost=te:GetCost()
				if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			end
		end
	end
end

function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b5)
end
function s.tgchk(c)
	return c:IsSetCard(0x9b5) and c:IsLocation(LOCATION_GRAVE)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_ONFIELD,0,nil)
	if ct>0 and Duel.DiscardDeck(tp,ct,REASON_EFFECT)>0 then
		local g=Duel.GetOperatedGroup()
		local val=g:FilterCount(s.tgchk,nil)
		if val>0 then
			Duel.Damage(1-tp,val*200,REASON_EFFECT)
		end
	end
end