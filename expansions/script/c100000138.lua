--Argyndr from the Molten Core
--L'Argyndr dal Nucleo Fuso
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,9,2,nil,nil,99)
	--[[If your opponent Special Summons a monster(s) from the Extra Deck (except during the Damage Step) (Quick Effect):
	You can detach 2 materials from this card, then target 1 of those face-up monsters; look at your opponent's Extra Deck, then attach 1 monster from it to this card as material,
	but it must have the same monster card type (Fusion, Synchro, Xyz, Link, Bigbang or Time Leap) as the targeted monster.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_SPSUMMON_SUCCESS,s.cfilter,id,LOCATION_MZONE,nil,LOCATION_MZONE)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetFunctions(nil,aux.DetachSelfCost(2),s.target,s.operation)
	c:RegisterEffect(e1)
	--[[Monsters your opponent controls that were Special Summoned from the Extra Deck,
	and that have the same monster card type (Fusion, Synchro, Xyz, Link, Bigbang or Time Leap) as a monster attached to this card, cannot activate their effects.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.tgval)
	c:RegisterEffect(e2)
end
function s.cfilter(c,_,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.atfilter(c,types)
	return c:IsMonster(types) and c:IsCanOverlay()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(Card.IsCanBeEffectTarget,nil,e):Filter(s.filter,nil)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc) end
	if chk==0 then
		return e:GetHandler():IsMonster(TYPE_XYZ) and #g>0 and Duel.GetExtraDeckCount(1-tp)>0
	end
	Duel.HintMessage(tp,HINTMSG_TARGET)
	local sg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(sg)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ex=Duel.GetExtraDeck(1-tp)
	if #ex==0 then return end
	Duel.ConfirmCards(tp,ex)
	
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsMonster(TYPE_XYZ) and not c:IsImmuneToEffect(e) and tc:IsRelateToChain() and tc:IsFaceup() then
		local types=tc:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_BIGBANG|TYPE_TIMELEAP)
		local g=Duel.Select(HINTMSG_ATTACH,false,tp,s.atfilter,tp,0,LOCATION_EXTRA,1,1,nil,types)
		if #g>0 then
			Duel.BreakEffect()
			Duel.Attach(g:GetFirst(),c)
		end
	end
end

--E2
function s.tgval(e,c)
	local types=c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_BIGBANG|TYPE_TIMELEAP)
	return types~=0 and c:IsSummonLocation(LOCATION_EXTRA) and e:GetHandler():GetOverlayGroup():IsExists(Card.IsMonster,1,nil,types)
end