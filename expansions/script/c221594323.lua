--[[
Voidictator Deity - Sauriel the Cosmic Arbiter
Divinità Vuotodespota - Sauriel l'Arbitro Cosmico
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+100
	end
	--bigbang
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,s.matfilter,2,2,s.gcheck)
	c:EnableReviveLimit()
	--You can only control 1 "Voidictator Deity - Sauriel the Cosmic Arbiter".
	c:SetUniqueOnField(1,0,id)
	--[[If this card is Bigbang Summoned: You can activate this effect; banish 1 random face-down card from your Extra Deck face-up, and if you do, this card gains ATK/DEF equal to that card's ATK.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.BigbangSummonedCond)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--[[If this card leaves the field because of an opponent's card, or if this card is banished because of a "Voidictator" card you own:
	Return this card to the Extra Deck, then you can inflict damage to your opponent equal to the highest ATK among monsters your opponent controls (your choice, if tied).]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_REMOVE)
	e2x:SetCondition(s.thcon2)
	c:RegisterEffect(e2x)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
	--[[Up to thrice per turn, if your opponent Special Summons a Bigbang Monster(s): Activate this effect;
	this card gains the effects of 1 of those face-up monsters until the end of the next turn.]]
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.cfilter,s.progressive_id,LOCATION_MZONE,nil,LOCATION_MZONE,nil,nil,true)
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
function s.matfilter(c)
	return c:IsLevelAbove(8) and c:IsNeutral() and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_FIEND)
end
function s.gcheck(mg,bc,tp)
	return mg:IsExists(Card.IsSetCard,1,nil,ARCHE_VOIDICTATOR)
end

--E1
function s.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(false,s.rmfilter,tp,LOCATION_EXTRA,0,1,nil) and c:IsCanChangeStats()
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,c,1,c:GetControler(),c:GetLocation(),1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.rmfilter,tp,LOCATION_EXTRA,0,nil)
	local rg=g:RandomSelect(tp,1)
	if #rg>0 then
		local tc=rg:GetFirst()
		local val=tc:HasAttack() and tc:GetAttack() or nil
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 and val then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:IsCanChangeStats() then
				c:UpdateATKDEF(val,val,0,c)
			end
		end
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and not c:IsLocation(LOCATION_DECK|LOCATION_EXTRA)
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.thfilter(c)
	return c:IsFaceup() and c:HasAttack()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	local _,dam=Duel.Group(s.thfilter,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,nil,LOCATION_EXTRA)>0 then
		local _,dam=Duel.Group(s.thfilter,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
		if dam and dam>0 and Duel.SelectYesNo(tp,STRING_ASK_DAMAGE) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end

--E3
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_BIGBANG) and c:IsSummonPlayer(1-tp)
end
function s.checkfilter(c)
	return c:IsFaceup() and not c:IsForbidden()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(s.checkfilter,nil)
	if not c:IsRelateToChain() or c:IsFacedown() or #g<=0 then return end
	local tc=g:GetFirst()
	if #g>1 then
		Duel.HintMessage(tp,HINTMSG_SELECT)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		tc=sg:GetFirst()
	else
		Duel.HintSelection(Group.FromCards(tc))
	end
	if tc then
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
	end
end