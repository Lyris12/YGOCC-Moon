--Manual Mode
--Scripted by: XGlitchy30

local counter_list={0x1, 0x3, 0x4, 0x5}
-- for line in io.lines('strings.conf') do
	-- if line:sub(1,8)=="!counter" then
		-- local p1=line:find("0x")
		-- local v=tonumber(line:sub(p1,p1+5)) or tonumber(line:sub(p1,p1+4)) or tonumber(line:sub(p1,p1+3)) or tonumber(line:sub(p1,p1+2))
		-- if v then table.insert(counter_list,v) end
	-- end
-- end

local NUMLIST,NUMLIST2,NUMLIST3={},{},{}
for i=0,10000,100 do
	table.insert(NUMLIST,i)
end
for i=0,5000,100 do
	table.insert(NUMLIST2,i)
end
for i=0,100 do
	table.insert(NUMLIST3,i)
end

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCost(s.cost)
	e1:SetOperation(s.ops)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	Duel.RegisterFlagEffect(1-tp,id,0,0,1)
end
function s.ops(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ConfirmCards(1-tp,c)
	Duel.DisableShuffleCheck()
	Duel.Remove(c,POS_FACEUP,REASON_RULE)
	if c:GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(c:GetControler(),1,REASON_RULE)
	end
	local tk=Duel.CreateToken(1-tp,id)
	Duel.Remove(tk,POS_FACEUP,REASON_RULE)
	--Look at Deck
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetRange(LOCATION_REMOVED)
	e0:SetLabel(1)
	e0:SetOperation(s.deck_manual_actions)
	tk:RegisterEffect(Effect.Clone(e0))
	c:RegisterEffect(e0)
	
	--
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ALL-LOCATION_REMOVED,LOCATION_ALL-LOCATION_REMOVED,Group.FromCards(c,tk))
	for tc in aux.Next(g) do
		tc:ResetEffect(tc:GetOriginalCode(),RESET_CARD)
		for _,ct in ipairs(counter_list) do
			tc:EnableCounterPermit(ct,LOCATION_ALL)
		end
		--Manual Actions
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(aux.Stringid(id,14))
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_FREE_CHAIN)
		e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_BOTH_SIDE)
		e0:SetRange(LOCATION_ALL-LOCATION_DECK)
		e0:SetLabel(1)
		e0:SetOperation(s.manual_actions)
		tc:RegisterEffect(e0)
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(aux.Stringid(id,14))
		e0:SetType(EFFECT_TYPE_IGNITION)
		e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_BOTH_SIDE)
		e0:SetRange(LOCATION_ONFIELD)
		e0:SetTarget(function(effect,_,_,_,_,_,_,_,chk)
						if chk==0 then return true end
						Duel.SetChainLimit(aux.FALSE)
					end
					)
		e0:SetCondition(function(effect)
							return effect:GetHandler():IsFacedown()
						end)
		e0:SetOperation(s.manual_actions)
		tc:RegisterEffect(e0)
		--Generic Chains
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,15))
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
		e1:SetCost(s.chain_link_cost)
		e1:SetTarget(s.chain_link_tg)
		e1:SetOperation(s.chain_link_action)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id+2,15))
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
		e2:SetType(EFFECT_TYPE_ACTIVATE)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetCost(s.chain_link_cost)
		e2:SetTarget(s.chain_link_tg)
		e2:SetOperation(s.chain_link_action)
		tc:RegisterEffect(e2)
		--Spells/Traps tweaks
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_SET_AVAILABLE)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		tc:RegisterEffect(e4)
		local e5=e3:Clone()
		e5:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		tc:RegisterEffect(e5)
		local e6=e3:Clone()
		e6:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
		tc:RegisterEffect(e6)
		local kp=Effect.CreateEffect(tc)
		kp:SetType(EFFECT_TYPE_SINGLE)
		kp:SetCode(EFFECT_REMAIN_FIELD)
		tc:RegisterEffect(kp)
		--Battle Phase tweaks
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
		e3:SetCode(EFFECT_EXTRA_ATTACK)
		e3:SetValue(99)
		tc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
		e4:SetCode(EFFECT_DEFENSE_ATTACK)
		e4:SetValue(1)
		tc:RegisterEffect(e4)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
		e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e5:SetValue(1)
		tc:RegisterEffect(e5)
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
		e6:SetCode(EFFECT_DIRECT_ATTACK)
		tc:RegisterEffect(e6)
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e7:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
		e7:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e7:SetOperation(s.damageproc)
		tc:RegisterEffect(e7)
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
		e8:SetCode(EVENT_ATTACK_ANNOUNCE)
		e8:SetLabelObject(e4)
		e8:SetCondition(function (eff) return eff:GetHandler():IsDefensePos() end)
		e8:SetOperation(function (eff,p) local sel=Duel.SelectOption(p,aux.Stringid(id+5,2),aux.Stringid(id+5,3)) if sel==0 then eff:GetLabelObject():SetValue(0) else eff:GetLabelObject():SetValue(1) end end)
		tc:RegisterEffect(e8)
		-- local e8=Effect.CreateEffect(c)
		-- e8:SetType(EFFECT_TYPE_SINGLE)
		-- e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		-- e8:SetCode(EFFECT_CANNOT_SUMMON)
		-- e8:SetValue(1)
		-- tc:RegisterEffect(e8)
		-- local e9=e8:Clone()
		-- e9:SetCode(EFFECT_CANNOT_MSET)
		-- tc:RegisterEffect(e9)
	end
	--Global Manual Actions
	local ge=Effect.CreateEffect(c)
	ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge:SetCode(EVENT_FREE_CHAIN)
	ge:SetOperation(s.global_manual_actions)
	Duel.RegisterEffect(ge,tp)
	local ge=Effect.CreateEffect(tk)
	ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge:SetCode(EVENT_FREE_CHAIN)
	ge:SetOperation(s.global_manual_actions)
	Duel.RegisterEffect(ge,1-tp)
	--Remove Automatic Lost
	local ge=Effect.CreateEffect(c)
	ge:SetType(EFFECT_TYPE_FIELD)
	ge:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge:SetCode(EFFECT_CANNOT_LOSE_KOISHI)
	ge:SetTargetRange(1,1)
	Duel.RegisterEffect(ge,tp)
	--Add Draw Phase window
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetOperation(s.drawphase)
	Duel.RegisterEffect(e1,tp)
	--Unlimited KPro Normal Summon/Set Procs
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(999)
	Duel.RegisterEffect(e1,tp)
end

function s.deck_manual_actions(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if tp~=c:GetControler() then
		if not Duel.SelectYesNo(1-tp,aux.Stringid(id+4,13)) then return end
		Duel.ConfirmCards(1-c:GetControler(),Duel.GetFieldGroup(c:GetControler(),LOCATION_DECK,0))
	end
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,c:GetControler(),LOCATION_DECK,0,0,999,c)
	if #g>0 then
		for tc in aux.Next(g) do
			Duel.Hint(HINT_CARD,tp,tc:GetOriginalCode())
			local elist=global_card_effect_table[tc]
			for _,effect in ipairs(elist) do
				if effect and effect.GetLabel and effect:GetLabel()==1 then
					s.manual_actions(effect,tp,eg,ep,ev,re,r,rp)
				end
			end
		end
	end
	Duel.ShuffleDeck(c:GetControler())
end

function s.manual_actions(e,tp,eg,ep,ev,re,r,rp,g)
	local c = not g and Group.FromCards(e:GetHandler()) or g
	local cc=c:GetFirst()
	local b1=(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or cc:IsLocation(LOCATION_MZONE) and cc:IsFaceup()) and cc:IsSummonable(true,nil) and not g
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and cc:IsMSetable(true,nil) and not g
	local b22=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b3=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local b4=c:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_GRAVE)
	local b5=c:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_REMOVED)
	local b6=c:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_DECK+LOCATION_EXTRA)
	local b7=c:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_HAND+LOCATION_EXTRA)
	local b8=c:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
	local b9=c:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
	local b10=c:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_EXTRA)
	local b11=c:IsExists(function(fc) return fc:IsOnField() and fc:IsFaceup() end,1,nil) 
	local b12=c:IsExists(function(fc) return fc:IsLocation(LOCATION_MZONE) and fc:IsFaceup() end,1,nil)
	local b13=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	local b14=c:IsExists(function(fc) return fc:GetOverlayCount()>0 end,1,nil)
	local b15=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,c)
	--
	local sel=aux.Option(id,tp,0,b1,b2,b22,b4,b7,b5,b6,b6,b6,b3,b8,b9,b3,b10,{b11,id+1,14},{b12,id+1,15},{b9,id+4,0},{true,id+4,1},{b13,id+4,7},{b14,id+4,9},{b15,id+5,4})
	--Normal Summon
	if sel==0 and not g then
		if tp~=c:GetControler() then
			Duel.HintSelection(Group.FromCards(c))
			if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,0)) then return end
		end
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(function(eff,card) if card==nil then return true end return true end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		Duel.Summon(tp,c,true,nil)
	--Normal Set
	elseif sel==1 and not g then
		if tp~=c:GetControler() then
			Duel.HintSelection(Group.FromCards(c))
			if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,0)) then return end
		end
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(123709,0))
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_PROC)
		e1:SetCondition(function(eff,card) if card==nil then return true end end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		Duel.MSet(tp,c,true,nil)
	--Special Summon
	elseif sel==2 then
		local fc=c:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_MZONE)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,0)) then return end
			end
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP+POS_FACEDOWN)
			Duel.SpecialSummon(tc,0,tp,p,true,true,pos)
		end
	--To GY
	elseif sel==3 then
		local fc=c:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_GRAVE)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,1)) then return end
			end
			Duel.SendtoGrave(tc,REASON_RULE,p)
		end
	--To hand
	elseif sel==4 then
		local fc=c:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_HAND)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,2)) then return end
			end
			Duel.SendtoHand(tc,p,REASON_RULE)
			Duel.ConfirmCards(1-tp,tc)
		end
	--Banish
	elseif sel==5 then
		local fc=c:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_REMOVED)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,3)) then return end
			end
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
			Duel.Remove(tc,pos,REASON_RULE,p)
		end
	--Shuffle into the Deck
	elseif sel==6 then
		local fc=c:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_DECK+LOCATION_EXTRA)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,4)) then return end
			end
			Duel.SendtoDeck(tc,p,SEQ_DECKSHUFFLE,REASON_RULE)
		end
	--To top of the Deck
	elseif sel==7 then
		local fc=c:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_DECK+LOCATION_EXTRA)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,4)) then return end
			end
			Duel.SendtoDeck(tc,p,SEQ_DECKTOP,REASON_RULE)
		end
		local og=fc:Filter(Card.IsLocation,nil,LOCATION_DECK)
		if #og<=1 then return end
		for pp=tp,1-tp,1-2*tp do
			local dg=og:Filter(Card.IsControler,nil,pp)
			if #dg>1 then
				Duel.SortDecktop(tp,pp,#dg)
			end
		end
	--To bottom of the Deck
	elseif sel==8 then
		local fc=c:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_DECK+LOCATION_EXTRA)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,4)) then return end
			end
			Duel.SendtoDeck(tc,p,SEQ_DECKBOTTOM,REASON_RULE)
		end
		local og=fc:Filter(Card.IsLocation,nil,LOCATION_DECK)
		if #og<=1 then return end
		for pp=tp,1-tp,1-2*tp  do
			local dg=og:Filter(Card.IsControler,nil,pp)
			if #dg>1 then
				Duel.SortDecktop(tp,pp,#dg)
				for i=1,#dg do
					local mg=Duel.GetDecktopGroup(pp,1)
					Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
				end
			end
		end
	--To Spells & Traps Zone
	elseif sel==9 then
		local fc=c:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_SZONE)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,5)) then return end
			end
			Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,true)
		end
	--Reveal
	elseif sel==10 then
		for tc in aux.Next(c) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,6)) then return end
			end
			Duel.ConfirmCards(1-tp,tc)
		end
	--Change Position
	elseif sel==11 then
		local fc=c:Filter(Card.IsLocation,nil,LOCATION_MZONE)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,7)) then return end
			end
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP+POS_FACEDOWN-c:GetPosition())
			Duel.ChangePosition(tc,pos)
		end
	--Set as Spell/Trap
	elseif sel==12 then
		for tc in aux.Next(c) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,8)) then return end
			end
			if tc:IsMonster() then
				tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
				local th=Effect.CreateEffect(tc)
				th:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				th:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
				th:SetCode(EVENT_TO_HAND)
				th:SetOperation(function(effect)
									effect:GetHandler():SetCardData(CARDDATA_TYPE,TYPE_MONSTER)
								end)
				th:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				tc:RegisterEffect(th)
				local td=th:Clone()
				td:SetCode(EVENT_TO_DECK)
				tc:RegisterEffect(td)
				local rem=th:Clone()
				rem:SetCode(EVENT_REMOVE)
				tc:RegisterEffect(rem)
				local tg=th:Clone()
				tg:SetCode(EVENT_TO_GRAVE)
				tc:RegisterEffect(tg)
				local sp=th:Clone()
				sp:SetCode(EVENT_SPSUMMON_SUCCESS)
				tc:RegisterEffect(sp)
				local mv=th:Clone()
				mv:SetCode(EVENT_MOVE)
				mv:SetCondition(function(effect) return not effect:GetHandler():IsLocation(LOCATION_SZONE) end)
				tc:RegisterEffect(mv)
			end
			if tc:IsLocation(LOCATION_SZONE) then
				Duel.ChangePosition(tc,POS_FACEDOWN_ATTACK)
			else
				Duel.SSet(tp,tc,p,false)
			end
		end
	--Send to ED face-up
	elseif sel==13 then
		local fc=c:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,9)) then return end
			end
			if not tc:IsType(TYPE_PENDULUM) then
				local ogtyp=tc:GetOriginalType()
				tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+TYPE_PENDULUM+TYPE_EFFECT)
				local th=Effect.CreateEffect(tc)
				th:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				th:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
				th:SetCode(EVENT_TO_HAND)
				th:SetLabel(ogtyp)
				th:SetOperation(function(effect)
									effect:GetHandler():SetCardData(CARDDATA_TYPE,effect:GetLabel())
								end)
				th:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(th)
				local td=th:Clone()
				td:SetCode(EVENT_TO_DECK)
				tc:RegisterEffect(td)
				local rem=th:Clone()
				rem:SetCode(EVENT_REMOVE)
				tc:RegisterEffect(rem)
				local tg=th:Clone()
				tg:SetCode(EVENT_TO_GRAVE)
				tc:RegisterEffect(tg)
				local sp=th:Clone()
				sp:SetCode(EVENT_SPSUMMON_SUCCESS)
				tc:RegisterEffect(sp)
				local mv=th:Clone()
				mv:SetCode(EVENT_MOVE)
				mv:SetCondition(function(effect) return not effect:GetHandler():IsLocation(LOCATION_EXTRA) end)
				tc:RegisterEffect(mv)
			end
			Duel.SendtoExtraP(tc,p,REASON_RULE)
		end
	--Place Counters
	elseif sel==14 then
		local fc=c:Filter(function(x) return x:IsLocation(LOCATION_MZONE) and x:IsFaceup() end,nil)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,12)) then return end
			end
			local counter=Duel.AnnounceNumber(tp,table.unpack(counter_list))	   
			local ct=Duel.AnnounceNumber(0,table.unpack(NUMLIST3))
			if tc:GetCounter(counter)>=ct and Duel.SelectYesNo(tp,10) then
				tc:RemoveCounter(tp,counter,ct,REASON_RULE)
			else
				tc:AddCounter(counter,ct)
			end
		end
	--Change/Add/Reset stats
	elseif sel==15 then
		local fc=c:Filter(function(x) return x:IsLocation(LOCATION_MZONE) and x:IsFaceup() end,nil)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			Duel.HintSelection(Group.FromCards(tc))
			if tp~=tc:GetControler() then		
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+2,13)) then return end
			end
			while true do
				local opt=aux.Option(id+3,tp,0,true,true,true,true,true,true,true,true,true,true,true,true,{true,id+1,8})
				local effect,value=0,0
				if opt<=10 then
					local clonecheck,cloneval=false,false
					if opt==0 then
						opt=1
						clonecheck=true
					end
					if opt==1 then
						local mode=Duel.SelectOption(tp,aux.Stringid(id+3,1),aux.Stringid(id+3,12),aux.Stringid(id+3,13),aux.Stringid(id+3,14),aux.Stringid(id+3,15))
						if mode==0 then
							effect=EFFECT_SET_ATTACK_FINAL
							value=Duel.AnnounceNumber(tp,table.unpack(NUMLIST))
							if clonecheck then clonecheck=EFFECT_SET_DEFENSE_FINAL cloneval=value end
						elseif mode==1 then
							effect=EFFECT_UPDATE_ATTACK
							
							value=Duel.AnnounceNumber(tp,table.unpack(NUMLIST2))
							if clonecheck then clonecheck=EFFECT_UPDATE_DEFENSE cloneval=value end
						elseif mode==2 then
							effect=EFFECT_UPDATE_ATTACK
							
							value=Duel.AnnounceNumber(tp,table.unpack(NUMLIST2))*-1
							if clonecheck then clonecheck=EFFECT_UPDATE_DEFENSE cloneval=value end
						elseif mode==3 then
							effect=EFFECT_SET_ATTACK_FINAL
							local ct=Duel.AnnounceNumber(tp,table.unpack({2,3,4,5,6,7,8,9,10,100,1000}))
							value=tc:GetAttack()*ct
							if clonecheck then clonecheck=EFFECT_SET_DEFENSE_FINAL cloneval=tc:GetDefense()*ct end
						elseif mode==4 then
							effect=EFFECT_SET_ATTACK_FINAL
							
							local ct=Duel.AnnounceNumber(tp,table.unpack({2,3,4,5,6,7,8,9,10,100,1000}))
							value=math.floor(tc:GetAttack()/ct)
							if clonecheck then clonecheck=EFFECT_SET_DEFENSE_FINAL cloneval=math.floor(tc:GetDefense()/ct) end
						end
					elseif opt==2 then
						local mode=Duel.SelectOption(tp,aux.Stringid(id+3,1),aux.Stringid(id+3,12),aux.Stringid(id+3,13),aux.Stringid(id+3,14),aux.Stringid(id+3,15))
						if mode==0 then
							effect=EFFECT_SET_DEFENSE_FINAL
							value=Duel.AnnounceNumber(tp,table.unpack(NUMLIST))
						elseif mode==1 then
							effect=EFFECT_UPDATE_DEFENSE
							value=Duel.AnnounceNumber(tp,table.unpack(NUMLIST2))
						elseif mode==2 then
							effect=EFFECT_UPDATE_DEFENSE
							value=Duel.AnnounceNumber(tp,table.unpack(NUMLIST2))*-1
						elseif mode==3 then
							effect=EFFECT_SET_DEFENSE_FINAL
							local ct=Duel.AnnounceNumber(tp,table.unpack({2,3,4,5,6,7,8,9,10,100,1000}))
							value=tc:GetDefense()*ct
						elseif mode==4 then
							effect=EFFECT_SET_DEFENSE_FINAL
							local ct=Duel.AnnounceNumber(tp,table.unpack({2,3,4,5,6,7,8,9,10,100,1000}))
							value=math.floor(tc:GetDefense()/ct)
						end
					elseif opt==3 then
						effect=(tc:IsType(TYPE_XYZ)) and EFFECT_CHANGE_RANK or (tc:IsType(TYPE_TIMELEAP)) and EFFECT_FUTURE or EFFECT_CHANGE_LEVEL
						value=Duel.AnnounceLevel(tp,1,13)
					elseif opt==4 then
						effect=EFFECT_CHANGE_ATTRIBUTE
						value=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL-tc:GetAttribute())
					elseif opt==5 then
						effect=EFFECT_ADD_ATTRIBUTE
						value=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL-tc:GetAttribute())
					elseif opt==6 then
						effect=EFFECT_CHANGE_RACE
						value=Duel.AnnounceRace(tp,1,RACE_ALL-tc:GetRace())
					elseif opt==7 then
						effect=EFFECT_ADD_RACE
						value=Duel.AnnounceRace(tp,1,RACE_ALL-tc:GetRace())
					elseif opt==8 then
						effect=EFFECT_CHANGE_CODE
						value=Duel.AnnounceCard(tp)
					elseif opt==9 then
						effect=EFFECT_ADD_CODE
						value=Duel.AnnounceCard(tp)
					elseif opt==10 then
						effect=EFFECT_ADD_TYPE
						value=TYPE_TUNER
					end
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
					e1:SetCode(effect)
					e1:SetValue(value)
					e1:SetLabel(2)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
					if clonecheck then
						local e2=e1:Clone()
						e2:SetCode(clonecheck)
						e2:SetValue(cloneval)
						tc:RegisterEffect(e2)
					end
				elseif opt==11 then
					local elist=global_card_effect_table[tc]
					for _,ce in ipairs(elist) do
						if ce and ce.GetLabel and ce:GetLabel()==2 then
							ce:Reset()
						end
					end
					return
				else
					return
				end
			end
		end
	--Give Control
	elseif sel==16 then
		local fc=c:Filter(Card.IsOnField,nil)
		for tc in aux.Next(c) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+4,2)) then return end
			end
			Duel.GetControl(tc,1-tc:GetControler())
		end
	--Change Ownership
	elseif sel==17 then
		for tc in aux.Next(c) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+4,3)) then return end
			end
			if tc:GetFlagEffect(id)<=0 then
				tc:RegisterFlagEffect(id,0,0,1)
			else
				tc:ResetFlagEffect(id)
			end
		end
	--Attach as Overlay Unit
	elseif sel==18 then
		for tc in aux.Next(c) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+4,8)) then return end
			end
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			Duel.Overlay(g:GetFirst(),Group.FromCards(tc))
		end
	--Detach Overlay Unit
	elseif sel==19 then
		local fc=c:Filter(function(x) return x:GetOverlayCount()>0 end,nil)
		for tc in aux.Next(fc) do
			local p=tc:GetFlagEffect(id)>0 and 1-tc:GetOwner() or tc:GetOwner()
			if tp~=tc:GetControler() then
				Duel.HintSelection(Group.FromCards(tc))
				if not Duel.SelectYesNo(1-tp,aux.Stringid(id+4,10)) then return end
			end
			local g=tc:GetOverlayGroup():Select(tp,1,99,nil)
			Duel.SendtoGrave(g,nil,REASON_RULE)
		end
	--Summon on top of other cards (Xyz Change)
	elseif sel==20 then
		for tc in aux.Next(c) do
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
			Duel.Overlay(tc,g)
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP+POS_FACEDOWN)
		end
	end
end

function s.global_manual_actions(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local TP=tp
	-- local opt=Duel.SelectOption(tp,aux.Stringid(id+2,10),aux.Stringid(id+2,11))
	-- if opt==1 then tp=1-tp end
	--
	local b1=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
	local b2=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
	local b3=Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)>0
	local b4=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b5=Duel.GetFlagEffect(tp,5001)==0
	--
	local sel=aux.Option(id+1,TP,0,{true,id+2,14},b1,b1,b1,b2,{b1,id+2,10},b3,b4,true,true,{b1,id+4,11},{b3,id+4,12},{b5,id+4,14})
	--Modify LP
	if sel==0 then
		local mode=Duel.SelectOption(TP,aux.Stringid(id+2,14),aux.Stringid(id+3,12),aux.Stringid(id+3,13),aux.Stringid(id+3,14),aux.Stringid(id+3,15))
		local value=0
		if mode==0 then
			value=Duel.AnnounceNumber(TP,table.unpack(NUMLIST))
		elseif mode==1 then
			local ct=Duel.AnnounceNumber(TP,table.unpack(NUMLIST2))
			value=Duel.GetLP(tp)+ct
		elseif mode==2 then
			local ct=Duel.AnnounceNumber(TP,table.unpack(NUMLIST2))
			value=Duel.GetLP(tp)-ct
		elseif mode==3 then
			local ct=Duel.AnnounceNumber(TP,table.unpack({2,3,4,5,6,7,8,9,10,100,1000}))
			value=Duel.GetLP(tp)*ct
		elseif mode==4 then
			local ct=Duel.AnnounceNumber(TP,table.unpack({2,3,4,5,6,7,8,9,10,100,1000}))
			value=math.floor(Duel.GetLP(tp)/ct)
		end
		Duel.SetLP(tp,value)
	--Draw
	elseif sel==1 then
		local max=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local nlist={}
		for i=1,max do
			table.insert(nlist,i)
		end
		local ct=Duel.AnnounceNumber(TP,table.unpack(nlist))
		Duel.Draw(tp,ct,REASON_RULE)
	--Mill
	elseif sel==2 then
		local max=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local nlist={}
		for i=1,max do
			table.insert(nlist,i)
		end
		local ct=Duel.AnnounceNumber(TP,table.unpack(nlist))
		local g=Duel.GetDecktopGroup(tp,ct)
		Duel.SendtoGrave(g,REASON_RULE)
	--Excavate
	elseif sel==3 then
		local max=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local nlist={}
		for i=1,max do
			table.insert(nlist,i)
		end
		local ct=Duel.AnnounceNumber(TP,table.unpack(nlist))
		Duel.ConfirmDecktop(tp,ct)
		
		local top=Duel.GetDecktopGroup(tp,ct)
		if #top>0 and Duel.SelectYesNo(tp,aux.Stringid(id+5,5)) then
			local g=top:Select(tp,1,#top,nil)
			top:Sub(g)
			if #g>0 then
				local elist=global_card_effect_table[g:GetFirst()]
				for _,effect in ipairs(elist) do
					if effect and effect.GetLabel and effect:GetLabel()==1 then
						s.manual_actions(effect,tp,eg,ep,ev,re,r,rp,g)
					end
				end
			end
		end
		if #top>0 and Duel.SelectYesNo(tp,aux.Stringid(id+5,6)) then
			local elist=global_card_effect_table[top:GetFirst()]
			for _,effect in ipairs(elist) do
				if effect and effect.GetLabel and effect:GetLabel()==1 then
					s.manual_actions(effect,tp,eg,ep,ev,re,r,rp,top)
				end
			end
		else
			Duel.ShuffleDeck(tp)
		end
	--Show Hand
	elseif sel==4 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		Duel.ConfirmCards(1-tp,g)
		if Duel.SelectYesNo(tp,aux.Stringid(id+4,15)) then
			local sg=g:Select(1-tp,0,999,nil)
			if #sg>0 then
				local elist=global_card_effect_table[sg:GetFirst()]
				for _,effect in ipairs(elist) do
					if effect and effect.GetLabel and effect:GetLabel()==1 then
						s.manual_actions(effect,1-tp,eg,ep,ev,re,r,rp,sg)
					end
				end
			end
		end
	--Show Deck
	elseif sel==5 then
		local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
		Duel.ConfirmCards(1-tp,g)
		if Duel.SelectYesNo(tp,aux.Stringid(id+4,15)) then
			local sg=g:Select(1-tp,0,999,nil)
			if #sg>0 then
				local elist=global_card_effect_table[sg:GetFirst()]
				for _,effect in ipairs(elist) do
					if effect and effect.GetLabel and effect:GetLabel()==1 then
						s.manual_actions(effect,1-tp,eg,ep,ev,re,r,rp,sg)
					end
				end
			end
		end
	--Show ED
	elseif sel==6 then
		local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
		Duel.ConfirmCards(1-tp,g)
		if Duel.SelectYesNo(tp,aux.Stringid(id+4,15)) then
			local sg=g:Select(1-tp,0,999,nil)
			if #sg>0 then
				local elist=global_card_effect_table[sg:GetFirst()]
				for _,effect in ipairs(elist) do
					if effect and effect.GetLabel and effect:GetLabel()==1 then
						s.manual_actions(effect,1-tp,eg,ep,ev,re,r,rp,sg)
					end
				end
			end
		end
	--SS Token
	elseif sel==7 then
		local max=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local nlist={}
		for i=1,max do
			table.insert(nlist,i)
		end
		local ct=Duel.AnnounceNumber(TP,table.unpack(nlist))
		for i=1,ct do
			local tk=Duel.CreateToken(tp,73915051)
			local pos=Duel.SelectPosition(tp,tk,POS_FACEUP)
			Duel.SpecialSummonStep(tk,0,tp,tp,true,true,pos)
		end
		Duel.SpecialSummonComplete()
	--Roll Dice
	elseif sel==8 then
		Duel.TossDice(tp,1)
	--Toss Coin
	elseif sel==9 then
		Duel.TossCoin(tp,1)
	--Shuffle Deck
	elseif sel==10 then
		Duel.ShuffleDeck(tp)
	--Shuffle Extra Deck
	elseif sel==11 then
		Duel.ShuffleExtra(tp)
	--Let Opponent perform a manual action
	elseif sel==12 then
		Duel.RegisterFlagEffect(1-tp,5001,0,0,1)
		s.chain_link_action(e,1-tp,eg,ep,ev,re,r,rp)
		Duel.ResetFlagEffect(1-tp,5001)
	end
end

function s.chain_link_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.SelectYesNo(tp,aux.Stringid(5006,0)) then
		s.chain_link_action(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.chain_link_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.SelectYesNo(tp,aux.Stringid(5006,1)) then
		e:SetProperty(e:GetProperty()|EFFECT_FLAG_CARD_TARGET)
		local g=Duel.SelectMatchingCard(tp,function(fc) return not fc:IsCode(id) end ,tp,LOCATION_ALL-LOCATION_DECK-LOCATION_EXTRA-LOCATION_HAND,LOCATION_ALL-LOCATION_DECK-LOCATION_EXTRA-LOCATION_HAND,0,999,nil)
		Duel.SetTargetCard(g)
	else
		e:SetProperty(e:GetProperty()&~EFFECT_FLAG_CARD_TARGET)
	end
end
function s.chain_link_action(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--
	while true do
		local sel=aux.Option(id+1,tp,8,true,true,true,{true,5006,2})
		if sel==0 then
			return
		elseif sel==1 then
			local g=Duel.SelectMatchingCard(tp,function(fc) return not fc:IsCode(id) end ,tp,LOCATION_ALL-LOCATION_DECK-LOCATION_EXTRA,LOCATION_ALL-LOCATION_DECK-LOCATION_EXTRA,0,999,nil)
			if #g>0 then
				if #g<=5 then
					Duel.HintSelection(g)
				end
				local elist=global_card_effect_table[g:GetFirst()]
				for _,effect in ipairs(elist) do
					if effect and effect.GetLabel and effect:GetLabel()==1 then
						s.manual_actions(effect,tp,eg,ep,ev,re,r,rp,g)
					end
				end
			end
		elseif sel==2 then
			s.global_manual_actions(e,tp,eg,ep,ev,re,r,rp)
		elseif sel==3 then
			s.deck_manual_actions(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end

function s.damageproc(e,p,eg,ep)
	if e:GetHandler():GetBattleTarget()~=nil and Duel.GetBattleDamage(e:GetHandlerPlayer())<=0 then return end
	local sel=Duel.SelectOption(ep,aux.Stringid(id+5,0),aux.Stringid(id+5,1))
	if sel==0 then return end
	local opt=Duel.SelectOption(ep,aux.Stringid(id+1,11),aux.Stringid(id+1,12),aux.Stringid(id+1,13),aux.Stringid(id+1,8))
	if opt==0 then
		Duel.ChangeBattleDamage(ep,e:GetHandler():GetAttack())
	elseif opt==1 then
		Duel.ChangeBattleDamage(ep,e:GetHandler():GetDefense())
	elseif opt==2 then
		local val=Duel.AnnounceNumber(ep,table.unpack(NUMLIST))
		Duel.ChangeBattleDamage(ep,val)
	end
end

function s.drawphase(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local b1=Duel.GetFieldGroupCount(p,LOCATION_DECK,0)>0
	--
	local sel=aux.Option(id+4,p,4,b1,b1,true)
	if sel==1 then
		local list={}
		for i=1,Duel.GetFieldGroupCount(p,LOCATION_DECK,0) do
			table.insert(list,i)
		end
		local val=Duel.AnnounceNumber(p,table.unpack(list))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
		e1:SetValue(val)
		Duel.RegisterEffect(e1,p)
	elseif sel==2 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,p)
	end
end
		