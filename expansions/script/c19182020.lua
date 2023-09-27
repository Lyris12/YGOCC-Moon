--Aircaster Megadeus Ri
--created by Alastar Rainford, coded by Lyris
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PSYCHO),3)
	--atk/def
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetValue(s.atkval)
	c:RegisterEffect(e0)
	--[[ Any monster in a Monster Zone that would leave the field is equipped to this card as Equip Spell with the following effect, instead.
	● The equipped monster gains 500 ATK.]]
	local g=Group.CreateGroup()
	g:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabelObject(g)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	c:RegisterEffect(e1)
	--[[You can banish 5 cards equipped to this card; each player discards their entire hand, then excavates cards from the top of their Deck,
	equal to the number of cards they discarded, and if they do, they send any Psychic monster to the GY, also they shuffle the rest into the Deck,
	also each player draws cards equal to the total number of Psychic monsters sent to the GYs by this effect.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_HANDES|CATEGORY_DECKDES|CATEGORY_TOGRAVE|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT(EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsInBackrow,0,LOCATION_SZONE,LOCATION_SZONE,nil)*500
end

function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(s.repfilter,c,LOCATION_MZONE)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=#g end
	local container=e:GetLabelObject()
	container:Clear()
	for tc in aux.Next(g) do
		Duel.HintSelection(Group.FromCards(tc))
		if Duel.EquipAndRegisterLimit(e,tp,tc,c,true,true) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	Duel.EquipComplete()
	container:Merge(g)
	return true
end
function s.repval(e,c)
	return e:GetLabelObject():IsContains(c)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()
	if chk==0 then return g:IsExists(Card.IsAbleToRemoveAsCost,5,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:FilterSelect(tp,Card.IsAbleToRemoveAsCost,5,5,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local h1,ct1=Duel.GetHand(tp)
	local h2,ct2=Duel.GetHand(1-tp)
	if chk==0 then return (ct1+ct2)>0
		and (ct1==0 or h1:FilterCount(Card.IsDiscardable,nil,REASON_EFFECT)==ct1)
		and (ct2==0 or h2:FilterCount(Card.IsDiscardable,nil,REASON_EFFECT)==ct2)
		and Duel.IsPlayerCanDiscardDeck(tp,ct1+ct2) and Duel.IsPlayerCanDiscardDeck(1-tp,ct1+ct2)
		and Duel.IsPlayerCanDraw(tp) and Duel.IsPlayerCanDraw(1-tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local shuffle={false,false}
	local h1,ct1=Duel.GetHand(tp)
	local h2,ct2=Duel.GetHand(1-tp)
	local g=h1+h2
	g=g:Filter(Card.IsDiscardable,nil,REASON_EFFECT)
	local ct=Duel.SendtoGrave(g,REASON_EFFECT|REASON_DISCARD)
	local dct1,dct2 = Duel.GetDeckCount(p),Duel.GetDeckCount(1-p)
	if ct>0 and dct1+dct2>0 then
		Duel.BreakEffect()
		if ct<=dct1 then
			Duel.ConfirmDecktop(p,ct)
			shuffle[p+1]=true
		end
		if ct<=dct2 then
			Duel.ConfirmDecktop(1-p,ct)
			shuffle[2-p]=true
		end
		
		local sg=Duel.GetDecktopGroup(tp,ct)+Duel.GetDecktopGroup(1-tp,ct)
		local tg=sg:Filter(Card.IsRace,nil,RACE_PSYCHIC)
		local d=0
		if #tg>0 then
			Duel.DisableShuffleCheck()
			if Duel.SendtoGrave(tg,REASON_EFFECT|REASON_EXCAVATE)>0 then
				d=tg:FilterCount(Card.IsInGY,nil)
			end
		end
		
		if shuffle[p+1] then
			Duel.ShuffleDeck(p)
		end
		if shuffle[2-p] then
			Duel.ShuffleDeck(1-p)
		end
		
		if d>0 then
			Duel.Draw(p,d,REASON_EFFECT)
			Duel.Draw(1-p,d,REASON_EFFECT)
		end
	end
end
