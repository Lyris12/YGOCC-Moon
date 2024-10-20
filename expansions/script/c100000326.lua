--[[
Invernal of the War Tactics
Invernale delle Tattiche di Guerra
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_DARK),2)
	--Special Summon (from your Extra Deck) by Tributing 1 Level 4 or lower DARK monster you control while you control a Continuous Spell/Trap.
	local proc=Effect.CreateEffect(c)
	proc:SetDescription(id,0)
	proc:SetType(EFFECT_TYPE_FIELD)
	proc:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	proc:SetCode(EFFECT_SPSUMMON_PROC)
	proc:SetRange(LOCATION_EXTRA)
	proc:SetCondition(s.hspcon)
	proc:SetTarget(s.hsptg)
	proc:SetOperation(s.hspop)
	c:RegisterEffect(proc)
	--Summoning condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.linklimit)
	c:RegisterEffect(e1)
	--[[If this card is Link Summoned, or if another DARK monster(s) is Special Summoned to your field: You can target 1 DARK monster in your GY with a different original name
	from all face-up monsters you control; add it to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		aux.LinkSummonedCond,
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SHOPT()
	e3:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e3:SetFunctions(
		aux.AlreadyInRangeEventCondition(s.spcfilter),
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e3)
	--[[During your Main Phase: You can either banish 1 monster from your GY or detach 1 material from a DARK Xyz Monster you control;
	send the top 3 cards of your Deck to the GY, and if you do, gain 800 LP for each monster sent to the GY this way.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetCategory(CATEGORY_DECKDES|CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(
		nil,
		s.ddcost,
		s.ddtg,
		s.ddop
	)
	c:RegisterEffect(e4)
	--[[While this card points to a DARK "Number" Xyz Monster(s), monsters you control cannot attack your opponent directly,
	also all monsters you control gain 300 ATK/DEF x the combined number of materials attached to those monsters.]]
	c:CannotAttackDirectlyField(LOCATION_MZONE,LOCATION_MZONE,0,nil,aux.ThisCardPointsToCond(s.pointfilter))
	c:UpdateATKDEFField(s.atkval,nil,LOCATION_MZONE,LOCATION_MZONE,0,nil,aux.ThisCardPointsToCond(s.pointfilter))
end
--PROC
function s.hspfilter(c,tp,sc)
	return c:IsFaceup() and c:IsST(TYPE_CONTINUOUS) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:IsCanBeLinkMaterial(sc) and c:IsReleasable(REASON_SPSUMMON)
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.Group(s.hspfilter,tp,LOCATION_ONFIELD,0,nil,tp,c)
	return #g>0
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.Group(s.hspfilter,tp,LOCATION_ONFIELD,0,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	Duel.Release(tc,REASON_SPSUMMON)
end

--E2
function s.thfilter(c,g)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand() and not g:IsExists(Card.IsOriginalCodeRule,1,nil,c:GetOriginalCodeRule())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc,g) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,g)
	Duel.SetCardOperationInfo(tg,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Search(tc)
	end
end

--E4
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function s.ddcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local f=aux.BanishCost(Card.IsMonster,LOCATION_GRAVE,0,1)
	local b1=f(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,3,{b1,STRING_BANISH},{b2,STRING_DETACH})
	if opt==0 then
		f(e,tp,eg,ep,ev,re,r,rp,chk)
	elseif opt==1 then
		local tc=Duel.Select(HINTMSG_DEATTACHFROM,false,tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
		if tc then
			tc:RemoveOverlayCard(tp,1,1,REASON_COST)
		end
	end
end
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDiscardDeck(tp,3)
	end
	Duel.SetTargetPlayer(tp)
	aux.MillInfo(tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800)
end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTargetPlayer()
	local ct=Duel.DiscardDeck(p,3,REASON_EFFECT)
	if ct>0 then
		local g=Duel.GetGroupOperatedByThisEffect(e):Filter(Card.IsInGY,nil):Filter(Card.IsMonster,nil)
		if #g>0 then
			Duel.Recover(p,#g*800,REASON_EFFECT)
		end
	end
end

--E5
function s.pointfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup()
	local ct=Duel.GetXyzMaterialGroupCount(e:GetHandlerPlayer(),1,1,Card.IsContained,nil,g)
	return ct*300
end