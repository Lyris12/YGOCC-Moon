--Discepolo di Zextra
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--destroy and search
	local p1=Effect.CreateEffect(c)
	p1:SetDescription(aux.Stringid(id,0))
	p1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetCountLimit(1)
	p1:SetCondition(aux.PandActCheck)
	p1:SetTarget(cid.thtg)
	p1:SetOperation(cid.thop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1)
	--atk debuff
	local p2=Effect.CreateEffect(c)
	p2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	p2:SetRange(LOCATION_SZONE)
	p2:SetCode(EVENT_SPSUMMON_SUCCESS)
	p2:SetCondition(aux.PandActCheck)
	p2:SetOperation(cid.atop)
	c:RegisterEffect(p2)
	--MONSTER EFFECTS
	--special summon rule
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.sprcon)
	e1:SetOperation(cid.sprop)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(cid.atkcon)
	e2:SetValue(1200)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(cid.sccon)
	e3:SetTarget(cid.sctg)
	e3:SetOperation(cid.scop)
	c:RegisterEffect(e3)
end
--DESTROY AND SEARCH
--filters
function cid.thfilter(c)
	return (c:IsSetCard(0xf78) or c:IsSetCard(0xf79)) and c:IsAbleToHand()
end
---------
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--ATK DEBUFF
function cid.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
--SPECIAL SUMMON RULE
--filters
function cid.cfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(726)>0
end
----------
function cid.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_SZONE,0,c)
	return g:GetCount()>0 and ft>0
end
function cid.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_SZONE,0,c)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,1,1,nil)
	Duel.Destroy(sg,REASON_COST)
end
--ATK
--filters
function cid.dbfilter(c)
	return c:IsFacedown() or c:IsType(TYPE_MONSTER)
end
---------
function cid.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	local tp=Duel.GetTurnPlayer()
	return not Duel.IsExistingMatchingCard(cid.dbfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler()) 
		and tp==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
--SEARCH
--filters
function cid.dcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:GetPreviousControler()==tp
		and (c:IsPreviousLocation(LOCATION_MZONE) or c:IsPreviousLocation(LOCATION_SZONE) or c:IsPreviousLocation(LOCATION_FZONE) or c:IsPreviousLocation(LOCATION_PZONE)) 
end
function cid.scfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PANDEMONIUM) and c:IsLevel(7) and c:IsAbleToHand()
end
---------
function cid.sccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.dcfilter,1,nil,tp)
end
function cid.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
			Duel.ConfirmCards(1-tp,g)
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.Destroy(c,REASON_EFFECT)
			end
		end
	end
end