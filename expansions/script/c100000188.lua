--[[
Draconic Sage of the Fairy Circle
Saggio Draconico del Circolo Fatato
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	--[[If this card is Synchro Summoned: You can target 1 Plant or Insect monster in your GY; add it to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetCondition(aux.SynchroSummonedCond)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--[[When a monster your opponent controls activates its effect (Quick Effect): You can banish 1 Plant or Insect monster from your hand or GY; destroy that monster, and if you do inflict damage to your opponent equal to half its original ATK, then gain LP equal to the damage inflicted to your opponent.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE|CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(s.discon)
	e2:SetCost(aux.BanishCost(s.cfilter,LOCATION_HAND|LOCATION_GRAVE))
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
--E1
function s.thfilter(c)
	return c:IsMonster() and c:IsRace(RACE_PLANT|RACE_INSECT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetCardOperationInfo(sg,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Search(tc,tp)
	end
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local p,loct=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return loct==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and p==1-tp
end
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_PLANT|RACE_INSECT)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToChain(ev)
	if chk==0 then return relation end
	if relation then
		local val=math.floor(rc:GetBaseAttack()/2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,rc:GetControler(),rc:GetLocation())
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,0,rc:GetPreviousLocation())
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) and Duel.Destroy(rc,REASON_EFFECT)>0 then
		local value=Duel.Damage(1-tp,rc:GetBaseAttack()/2,REASON_EFFECT)
		if value>0 then
			Duel.BreakEffect()
			Duel.Recover(tp,value,REASON_EFFECT)
		end
	end
end