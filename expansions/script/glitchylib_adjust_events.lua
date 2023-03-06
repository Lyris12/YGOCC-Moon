GlitchyAdjust = GlitchyAdjust or {}

local function register_adjust_checks()
	--Event: Monster(s) gains/loses ATK/DEF/Level
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(GlitchyAdjust.RegisterFlagsATKDEF)
	Duel.RegisterEffect(e1,0)
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetOperation(GlitchyAdjust.RaiseATKDEFChainEvent(true))
	Duel.RegisterEffect(e2,0)
	local e3=Effect.GlobalEffect()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetOperation(GlitchyAdjust.RaiseATKDEFAdjustEvent)
	Duel.RegisterEffect(e3,0)
end

--Register the flags for checking the previous and current state of the ATK/DEF/Level of monsters
FLAG_CURRENT_ATK    = 285
FLAG_PREVIOUS_ATK   = 284
FLAG_CURRENT_DEF    = 385
FLAG_PREVIOUS_DEF   = 384
FLAG_CURRENT_LEVEL  = 585
FLAG_PREVIOUS_LEVEL = 584

FLAG_PREVENT_ADJUST_ATKDEF = 285

EVENT_CHANGED_ATK				=	111000000 
EVENT_CHANGED_DEF				=	111000001 
EVENT_GAINED_ATK				=	111000002 
EVENT_GAINED_DEF				=	111000003 
EVENT_LOST_ATK					=	111000004 
EVENT_LOST_DEF					=	111000005 
EVENT_GAINED_ATK_FROM_ORIGINAL	=	111000006 
EVENT_GAINED_DEF_FROM_ORIGINAL	=	111000007 
EVENT_LOST_ATK_FROM_ORIGINAL	=	111000008 
EVENT_LOST_DEF_FROM_ORIGINAL	=	111000009 
EVENT_CHANGED_LEVEL				=	111000010

function GlitchyAdjust.RegisterFlagsATKDEF(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0xff,0xff,nil)
	for tc in aux.Next(g) do
		if tc:HasAttack() then
			if not tc:HasFlagEffect(FLAG_CURRENT_ATK) then
				local atk=tc:GetAttack()
				if atk<0 then atk=0 end			
				tc:RegisterFlagEffect(FLAG_CURRENT_ATK,0,0,1,atk)
				tc:RegisterFlagEffect(FLAG_PREVIOUS_ATK,0,0,1,atk)
			end
		else
			if tc:HasFlagEffect(FLAG_CURRENT_ATK,FLAG_PREVIOUS_ATK) then
				tc:ResetFlagEffect(FLAG_CURRENT_ATK)
				tc:ResetFlagEffect(FLAG_PREVIOUS_ATK)
			end
		end
			
		if tc:HasDefense() then
			if not tc:HasFlagEffect(FLAG_CURRENT_DEF) then
				local def=tc:GetDefense()
				if def<0 then def=0 end
				tc:RegisterFlagEffect(FLAG_CURRENT_DEF,0,0,1,def)
				tc:RegisterFlagEffect(FLAG_PREVIOUS_DEF,0,0,1,def)
			end
		else
			if tc:HasFlagEffect(FLAG_CURRENT_DEF,FLAG_PREVIOUS_DEF) then
				tc:ResetFlagEffect(FLAG_CURRENT_DEF)
				tc:ResetFlagEffect(FLAG_PREVIOUS_DEF)
			end
		end
		
		if tc:HasLevel() then
			if not tc:HasFlagEffect(FLAG_CURRENT_LEVEL) then
				local lv=tc:GetLevel()
				tc:RegisterFlagEffect(FLAG_CURRENT_LEVEL,0,0,1,lv)
				tc:RegisterFlagEffect(FLAG_PREVIOUS_LEVEL,0,0,1,lv)
			end
		else
			if tc:HasFlagEffect(FLAG_CURRENT_LEVEL,FLAG_PREVIOUS_LEVEL) then
				tc:ResetFlagEffect(FLAG_CURRENT_LEVEL)
				tc:ResetFlagEffect(FLAG_PREVIOUS_LEVEL)
			end
		end
	end
end

--Filters for cards that have changed stats
function GlitchyAdjust.ChangedStatFilterTemplate(func,flag)
	return	function(c)
				if not c:HasFlagEffect(flag) then return false end
				return func(c)~=c:GetFlagEffectLabel(flag)
			end
end
function GlitchyAdjust.ChangedATKFilter(c)
	return GlitchyAdjust.ChangedStatFilterTemplate(Card.GetAttack,FLAG_CURRENT_ATK)(c)
end
function GlitchyAdjust.ChangedDEFFilter(c)
	return GlitchyAdjust.ChangedStatFilterTemplate(Card.GetDefense,FLAG_CURRENT_DEF)(c)
end
function GlitchyAdjust.ChangedLevelFilter(c)
	return GlitchyAdjust.ChangedStatFilterTemplate(Card.GetLevel,FLAG_CURRENT_LEVEL)(c)
end

function GlitchyAdjust.RaiseATKDEFChainEvent(prevent_adjust_event)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				---------------------------------------
				--ATK
				local g=Duel.GetMatchingGroup(GlitchyAdjust.ChangedATKFilter,tp,0x7f,0x7f,nil)
				local changed_atk_g		=Group.CreateGroup() 
				local gained_atk_g		=Group.CreateGroup() 
				local lost_atk_g		=Group.CreateGroup() 
				local og_gained_atk_g	=Group.CreateGroup() 
				local og_lost_atk_g		=Group.CreateGroup() 
				
				for tc in aux.Next(g) do
					--Step 1: Put monsters that changed ATK in correct group, and save the ATK previous to the change
					local atk=tc:GetAttack()
					local prevatk=0
					if tc:HasFlagEffect(FLAG_CURRENT_ATK) then
						prevatk=tc:GetFlagEffectLabel(FLAG_CURRENT_ATK)
					end
					changed_atk_g:AddCard(tc)
					
					--Step 2: Sort the monster into a specific group, depending on the type of change
					if prevatk>atk then
						lost_atk_g:AddCard(tc)
					else
						gained_atk_g:AddCard(tc)
					end
					if prevatk<=tc:GetBaseAttack() and atk>tc:GetBaseAttack() then
						og_gained_atk_g:AddCard(tc)
					elseif prevatk>=tc:GetBaseAttack() and atk<tc:GetBaseAttack() then
						og_lost_atk_g:AddCard(tc)
					end
					
					--Step 3: Reset flags with previous values and register new flags with new stats values
					tc:ResetFlagEffect(FLAG_PREVIOUS_ATK)
					tc:ResetFlagEffect(FLAG_CURRENT_ATK)
					local atk_flag = (atk>0) and atk or 0
					local prevatk_flag = (prevatk>0) and prevatk or 0
					tc:RegisterFlagEffect(FLAG_PREVIOUS_ATK,0,0,1,prevatk_flag)
					tc:RegisterFlagEffect(FLAG_CURRENT_ATK,0,0,1,atk_flag)
				end
				
				---------------------------------------
				--DEF
				local dg=Duel.GetMatchingGroup(GlitchyAdjust.ChangedDEFFilter,tp,0x7f,0x7f,nil)
				local changed_def_g		=Group.CreateGroup() 
				local gained_def_g		=Group.CreateGroup() 
				local lost_def_g		=Group.CreateGroup() 
				local og_gained_def_g	=Group.CreateGroup() 
				local og_lost_def_g		=Group.CreateGroup()
				
				for tc in aux.Next(dg) do
					local def=tc:GetDefense()
					local prevdef=0
					if tc:HasFlagEffect(FLAG_CURRENT_DEF) then
						prevdef=tc:GetFlagEffectLabel(FLAG_CURRENT_DEF)
					end
					changed_def_g:AddCard(tc)
					
					if prevdef>def then
						lost_def_g:AddCard(tc)
					else
						gained_def_g:AddCard(tc)
					end
					if prevdef<=tc:GetBaseDefense() and def>tc:GetBaseDefense() then
						og_gained_def_g:AddCard(tc)
					elseif prevdef>=tc:GetBaseDefense() and def<tc:GetBaseDefense() then
						og_lost_def_g:AddCard(tc)
					end
					
					tc:ResetFlagEffect(FLAG_PREVIOUS_DEF)
					tc:ResetFlagEffect(FLAG_CURRENT_DEF)
					local def_flag = (def>0) and def or 0
					local prevdef_flag = (prevdef>0) and prevdef or 0
					tc:RegisterFlagEffect(FLAG_PREVIOUS_DEF,0,0,1,prevdef_flag)
					tc:RegisterFlagEffect(FLAG_CURRENT_DEF,0,0,1,def_flag)
				end
				
				---------------------------------------
				--LEVEL
				local lvg=Duel.GetMatchingGroup(GlitchyAdjust.ChangedLevelFilter,tp,0x7f,0x7f,nil)
				if #lvg>0 then
					for lvc in aux.Next(lvg) do
						local prevlv=lvc:GetFlagEffectLabel(FLAG_CURRENT_LEVEL)
						lvc:ResetFlagEffect(FLAG_PREVIOUS_LEVEL)
						lvc:ResetFlagEffect(FLAG_CURRENT_LEVEL)
						lvc:RegisterFlagEffect(FLAG_PREVIOUS_LEVEL,0,0,1,prevlv)
						lvc:RegisterFlagEffect(FLAG_CURRENT_LEVEL,0,0,1,lvc:GetLevel())
					end
				end
				
				
				--RAISE EVENTS
				if #changed_atk_g>0 then
					Duel.RaiseEvent(changed_atk_g,EVENT_CHANGED_ATK,re,REASON_EFFECT,rp,ep,0)
				end
				if #gained_atk_g>0 then
					Duel.RaiseEvent(gained_atk_g,EVENT_GAINED_ATK,re,REASON_EFFECT,rp,ep,0)
				end
				if #lost_atk_g>0 then
					Duel.RaiseEvent(lost_atk_g,EVENT_LOST_ATK,re,REASON_EFFECT,rp,ep,0)
				end
				if #og_gained_atk_g>0 then
					Duel.RaiseEvent(og_gained_atk_g,EVENT_GAINED_ATK_FROM_ORIGINAL,re,REASON_EFFECT,rp,ep,0)
				end
				if #og_lost_atk_g>0 then
					Duel.RaiseEvent(og_lost_atk_g,EVENT_LOST_ATK_FROM_ORIGINAL,re,REASON_EFFECT,rp,ep,0)
				end
				
				if #changed_def_g>0 then
					Duel.RaiseEvent(changed_def_g,EVENT_CHANGED_DEF,re,REASON_EFFECT,rp,ep,0)
				end
				if #gained_def_g>0 then
					Duel.RaiseEvent(gained_def_g,EVENT_GAINED_DEF,re,REASON_EFFECT,rp,ep,0)
				end
				if #lost_def_g>0 then
					Duel.RaiseEvent(lost_def_g,EVENT_LOST_DEF,re,REASON_EFFECT,rp,ep,0)
				end
				if #og_gained_def_g>0 then
					Duel.RaiseEvent(og_gained_def_g,EVENT_GAINED_DEF_FROM_ORIGINAL,re,REASON_EFFECT,rp,ep,0)
				end
				if #og_lost_def_g>0 then
					Duel.RaiseEvent(og_lost_def_g,EVENT_LOST_DEF_FROM_ORIGINAL,re,REASON_EFFECT,rp,ep,0)
				end
				
				if #lvg>0 then
					Duel.RaiseEvent(lvg,EVENT_CHANGED_LEVEL,re,REASON_EFFECT,rp,ep,0)
				end
				
				if prevent_adjust_event then
					Duel.RegisterFlagEffect(tp,FLAG_PREVENT_ADJUST_ATKDEF,RESET_CHAIN,0,1)
					Duel.RegisterFlagEffect(1-tp,FLAG_PREVENT_ADJUST_ATKDEF,RESET_CHAIN,0,1)
				end
			end
end

function GlitchyAdjust.RaiseATKDEFAdjustEvent(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,FLAG_PREVENT_ADJUST_ATKDEF)~=0 or Duel.GetFlagEffect(1-tp,FLAG_PREVENT_ADJUST_ATKDEF)~=0 then return end
	GlitchyAdjust.RaiseATKDEFChainEvent(false)(e,tp,eg,ep,ev,re,r,rp)
end

register_adjust_checks()