--Abyss Actor - Catchy Composer for KPro
function c103032023.initial_effect(c)
	aux.AddCodeList(c,id)
	aux.AddSetNameMonsterList(c,0x10ec)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,c103032023.FusionReqfilter, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x10ec),1,true,true) --1 non-level 4 or lower Abyss Actor Monster + 1 Abyss Actor Monster
	-- Adds Pendulum Properties
	aux.EnablePendulumAttribute(c)

	-- If Special Summoned from the Extra Deck; Take 1 Spell/Trap with "Abyss Actor" in its text and either Set it or Add it to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCategory(CATEGORY_SEARCH)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1, 103032023)
	e3:SetCondition(c103032023.spED)
    e3:SetTarget(c103032023.ToHandFieldCheck)
    e3:SetOperation(c103032023.STtofield)
	c:RegisterEffect(e3)
	
    --When the opponent activates a Card or Effect as long as we control another card: you can add 1 Pendulum monster from hand or field to extra deck;
    --The effect becomes "your Opponent Destroys 1 set card we control"
	local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,103032023)
    e4:SetCondition(c103032023.changeCon)
    e4:SetCost(c103032023.addAA)
    e4:SetTarget(c103032023.setCard)
    e4:SetOperation(c103032023.ChangeOp)
	c:RegisterEffect(e4)

	--Once per turn, during damage calculation, if an "Abyss Actor" battles a monster: your monster gains ATK equal to half Highest ATK/DEF of the monster it battles
    --until the end phase
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetRange(LOCATION_PZONE)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetCountLimit(1)
	e5:SetCondition(c103032023.ATKcon)
	e5:SetOperation(c103032023.ATKtarget)
	c:RegisterEffect(e5)
end

function c103032023.FusionReqfilter(c,fc,sumtype,tp)
	return c:IsFusionSetCard(0x10ec) and not c:IsLevelBelow(4)
end 

function c103032023.spED(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end

function c103032023.ToHandFieldCheck(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(c103032023.STfilter,tp,LOCATION_DECK,0,1,nil) and
		Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) --this effect will add a card from our deck to our hand in the current chain
end

function c103032023.STfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsSetNameMonsterListed(c,0x10ec) and (c:IsAbleToHand() or c:IsSSetable())
end

function c103032023.STtofield(e,tp,eg,ep,ev,re,r,rp)

	if Duel.GetLocationCount(tp, LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp, aux.Stringid(103032023,2))
	local g = Duel.SelectMatchingCard(tp,c103032023.STfilter,tp, LOCATION_DECK,0,1,1,nil)
	local tc = g:GetFirst()

	aux.ToHandOrElse(tc,tp,function()
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and g:GetFirst():IsSSetable()
	end,
		function()
		Duel.SSet(tp,tc)
	end, aux.Stringid(103032023,1)) --"Set it to your Field"
end

function c103032023.changeCon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetMatchingGroupCount(Card.IsExists,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) > 0
end

function c103032023.addAA(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.GetMatchingGroup(c103032023.CostFilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	local ac = Duel.SelectMatchingCard(tp, c103032023.CostFilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoExtraP(ac,tp, REASON_COST)
end

function c103032023.CostFilter(c,e)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec) and not c:IsForbidden()
end

function c103032023.setCard(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function c103032023.ChangeOp(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,c103032023.setDestruction)
end

function c103032023.setDestruction(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,103032023)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(1-tp,Card.IsFacedown,1-tp,LOCATION_MZONE | LOCATION_SZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function c103032023.ATKcon(e,tp,eg,ep,ev,re,r,rp)
	local MyMon, OpMon = Duel.GetBattleMonster(tp) --first value saves my monster and second saves the opponent's monster, both involved in a battle
	return MyMon and OpMon and MyMon:IsSetCard(0x10ec)
end

function c103032023.ATKtarget(e,tp,eg,ep,ev,re,r,rp)
	local MyMon, OpMon = Duel.GetBattleMonster(tp)
	local OpATKDEF = math.max(OpMon:GetAttack(), OpMon:GetDefense())/2
	if MyMon:IsFaceup() and MyMon:IsRelateToBattle() and MyMon:IsControler(tp) then
		local e6 = Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_UPDATE_ATTACK)
		e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e6:SetValue(OpATKDEF)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		MyMon:RegisterEffect(e6)
	end
end